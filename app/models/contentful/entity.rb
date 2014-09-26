module Contentful
  class Entity

    include ActiveModel::Model
    include ActiveModel::Validations
    include ActiveModel::Conversion
    extend ActiveModel::Naming

    attr_accessor :ct_object, :content_type, :locales, :space

    # Creates accessors to Entry.
    # Takes attributes of ContentType and space.
    # Returns localised accessors for Contentful Entry.
    # Example: If space has 2 locales (code: 'en-US', 'de-DE'), accessors 'name_en_us, name_de_de' will be created.
    def initialize(params)
      @space = params.delete(:space)
      setup_localised_attributes(content_type.fields, params)
    end

    # Get specified content type from Contentful.
    # Returns Contentful Content type object.
    def content_type
      @content_type = APICache.get("content_type_#{ct_type}") do
        space.content_types.find(ct_type)
      end
    end

    #Get all locales from Contentful Space.
    def locales
      @locales = APICache.get('locales') do
        space.locales.all
      end
    end

    # Saves the model and Contentful Entry object.
    # Takes attributes of Entry and space.
    # Returns localised accessors for Contentful Entry
    def save(space)
      if ct_object
        update(params_from_instance_variables)
      else
        ct_object = create(space)
      end
      object = self.class.new(ct_object.fields.merge(space: space))
      object.send(:assign_data, ct_object, space)
    end

    # Create the Contentful Entry object.
    # Takes a space and attributes from instance variables.
    # Returns an entry.
    def create(space)
      entry = content_type.entries.new
      set_localised_fields_for(entry, content_type)
      entry.save
    end

    # Updates an entry.
    # Takes hash with attributes.
    # Transform hash with localised file attributes and build File object.
    # Return model object.
    def update(params)
      assign_parameters_for_fields(content_type.fields, params)
      assign_attributes_from(params)
      ct_object = self.ct_object.save
      object = assign_data(ct_object)
      APICache.delete(object.cache_key)
      object
    end

    # Checks which Contentful type objects is.
    # Returns type and id of Contentful object.
    def cache_key
      "#{try(:ct_type) || 'asset'}_#{id}"
    end

    # Destroys an entry.
    def destroy
      ct_object.destroy
    end

    # Returns contentful ID of object.
    def id
      ct_object.try(:id)
    end

    # Creates localised form fields used in new and edit forms.
    def form_field_names
      content_type.fields.each_with_object([]) do |field, fields|
        locales.each do |locale|
          fields << "#{field.name.downcase}_#{locale.code.underscore.downcase}" if space.default_locale == locale.code || field.localized
        end
      end
    end

    class << self

      # Build a collection of entries from Contentful.
      # Takes space object.
      def all(space)
        items(space).map { |ct_object| build(ct_object, space) }
      end

      # Gets an entry from Contentful.
      # Takes space and entry id.
      # Returns build model, based on Contentful entry attributes.
      def find(space, id)
        APICache.get("#{self.try(:ct_type).to_s || 'asset'}_#{id}", period: 2) do
          build(item(space, id), space)
        end
      end

      # Gets a collection of entries.
      # Takes an space object.
      # Returns a Contentful::Management::Array of Contentful::Management::Entry.
      def items(space)
        space.entries.all(content_type: ct_type)
      end

      # Gets a specific entry.
      # Takes an id of entry and space object.
      # Returns a Contentful::Management::Entry.
      def item(space, id)
        space.entries.find(id)
      end

      # Takes content type ID.
      # Returns symbolised ID of Contentful content type.
      def content_type(content_type)
        define_singleton_method(:ct_type) do
          content_type.to_sym
        end
        define_method(:ct_type) do
          content_type.to_sym
        end
      end

      # Build and cache object based on Contentful object attributes
      # Takes Contentful object and space.
      # Returns build model object.
      def build(ct_object, space)
        object = self.new((ct_object.try(:instance_variable_get, :@fields) || {}).merge(space: space, auto: true))
        object = object.send(:assign_data, ct_object, space)
        APICache.store.set(object.cache_key, object)
        object
      end

    end

    private

    def self.has_one(attribute)
      define_method("#{attribute}") do |space|
        locale_code = space.default_locale
        ct_object_id = instance_variable_get("@#{attribute}_#{locale_code.underscore.downcase}_id")
        link = @ct_object.instance_variable_get(:@fields)[locale_code][attribute]
        unless ct_object_id.nil?
          case link['sys']['linkType']
            when 'Entry'
              APICache.get("entry_#{link['sys']['id']}") do
                space.entries.find(link['sys']['id'])
              end
            when 'Asset'
              APICache.get("asset_#{link['sys']['id']}") do
                space.assets.find(link['sys']['id'])
              end
          end
        end
      end
    end

    def assign_data(ct_object, space = nil)
      self.ct_object = ct_object
      self.space = space if space
      self
    end

    def set_localised_fields_for(entry, content_type)
      content_type.fields.each do |field|
        entry.send("#{field.id}_with_locales=", create_localised_params_for(field))
      end
    end

    # Assigns parameters to entry field.
    # Takes field from based content type.
    def create_localised_params_for(field)
      locales.each_with_object({}) do |locale, field_params|
        field_name = localized_field_name(field, locale)
        field_params[locale.code] = send(field_name) if respond_to? field_name
      end
    end

    # Create localized fields name.
    # Takes content type field and locale.
    def localized_field_name(field, locale)
      name = "#{field.id}_#{locale.code.underscore.downcase}"
      name += '_id' if field.link_type.in?(['Entry', 'Asset'])
      name
    end


    def setup_localised_attributes(fields, params)
      fields.each do |field|
        setup_localised_attributes_for_field(field, params)
      end
    end

    def setup_localised_attributes_for_field(field, params)
      locales.each do |locale|
        setup_attributes_for_field_and_locale(field, locale, params)
      end
    end

    def setup_attributes_for_field_and_locale(field, locale, params)
      setup_attributes_for_field(field, locale, params) if space.default_locale == locale.code || field.localized
    end

    def setup_attributes_for_field(field, locale, params)
      field_name = localized_field_name(field, locale)
      define_accessors(field_name)
      set_instance_variable(field_name, locale, params, field)
    end

    def set_instance_variable(field_name, locale, params, field = nil)
      auto_flag = params.delete(:auto)
      value = if field.link_type.in?(['Entry', 'Asset'])
                if params.present?
                  auto_flag ? extract_value_from_ct_object(field_name, locale, params, field) : extract_value_from_form(field_name, locale, params, field)
                end
              else
                params[locale.code] ? params[locale.code][field.id.to_sym] : params[field_name]
              end
      instance_variable_set("@#{field_name}", value)
    end

    def extract_value_from_ct_object(field_name, locale, params, field)
      params[field_name].presence || params[locale.code][field.id.to_sym].present? ? params[locale.code][field.id.to_sym]['sys']['id'] : params[field_name]
    end

    def extract_value_from_form(field_name, locale, params, field)
      if params[locale.code].present?
        params[locale.code][field.id.to_sym]['sys']['id'] if params[locale.code][field.id.to_sym].present?
      else
        params[field_name]
      end
    end

    # Define attributes accessor based on Contentful objects attributes.
    def define_accessors(field_name)
      define_singleton_method "#{field_name}=" do |value|
        instance_variable_set("@#{field_name}", value)
      end
      define_singleton_method field_name do
        instance_variable_get("@#{field_name}")
      end
    end

    def assign_parameters_for_fields(fields, params)
      fields.each do |field|
        assign_parameters_for_field(field, params)
      end
    end

    def assign_parameters_for_field(field, params)
      field_params = locales.each_with_object({}) do |locale, field_params|
        field_name = localized_field_name(field, locale)
        params.each do |name, value|
          field_params[locale.code] = value if respond_to?(field_name) && field_name == name
        end
      end
      self.ct_object.send("#{field.id}_with_locales=", field_params)
    end

    def assign_attributes_from(params)
      params.each do |name, value|
        self.public_send("#{name}=", value)
      end
    end

    def params_from_instance_variables
      instance_variables.each_with_object({}) do |name, params|
        params[name.to_s.gsub('@', '').to_sym] = instance_variable_get(name) if instance_variable_get(name).present?
      end
    end

  end
end
