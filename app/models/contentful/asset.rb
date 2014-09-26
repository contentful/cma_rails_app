module Contentful
  # Resource class for Contentful Asset objects.
  class Asset < Contentful::Entity
    ATTRIBUTES = [:title, :description, :file_url, :file_type, :file]
    CONTENTFUL_FIELDS = [:title, :description, :file]

    attr_accessor *ATTRIBUTES

    delegate :image_url, to: :ct_object

    # Create accessors to Asset.
    # Takes attributes of ContentType and space.
    # Returns localised accessors for Contentful Asset
    # Example: If space has 2 locales (code: 'en-US', 'de-DE'), accessors 'title_en_us, title_de_de' will be created.
    def initialize(params)
      @space = params.delete(:space)
      setup_localised_attributes(ATTRIBUTES, params)
    end

    # Saves the model and Contentful Asset object.
    # Takes attributes of Asset and space.
    # Returns localised accessors for Contentful Asset
    def save(space)
      if ct_object
        update(params_from_instance_variables)
      else
        ct_object = create(space)
      end
      object = self.class.new(ct_object.fields.merge(space: space))
      object.send(:assign_data, ct_object, space)
    end

    # Create the Contentful Asset object.
    # Takes a space and attributes from instance variables.
    # Returns an asset and process file.
    def create(space)
      asset = space.assets.new
      set_files_instance_variables
      assign_parameters_for(asset)
      asset.save
      asset.process_file
    end

    # Updates an asset.
    # Takes hash with attributes (title, description, file).
    # Transform hash with localised file attributes and build File object.
    # Return model object.
    def update(params)
      transform_file_parameters(params)
      assign_parameters_for_fields(CONTENTFUL_FIELDS, params)
      assign_attributes_from(params)
      ct_object = self.ct_object.save
      object = assign_data(ct_object)
      APICache.delete(object.cache_key)
      self.ct_object.process_file
      object
    end

    # Assigns parameters to asset field.
    # Takes field and hash with parameters.
    def assign_parameters_for_field(field, params)
      field_params = locales.each_with_object({}) do |locale, field_params|
        field_name = localized_field_name(field, locale)
        params.each do |name, value|
          field_params[locale.code] = value if respond_to?(field_name) && field_name == name
        end
      end
      self.ct_object.send("#{field}_with_locales=", field_params)
    end

    # Creates localised form fields used in new and edit forms.
    def form_field_names
      ATTRIBUTES.each_with_object([]) do |field, fields|
        locales.each do |locale|
          fields << "#{field.downcase}_#{locale.code.underscore.downcase}"
        end
      end
    end

    # Returns localised image in views.
    def form_image_url(params)
      field_name = params.delete(:field)
      locale_part = field_name.gsub('file_', '')
      locale = locales.select { |locale| locale.code.underscore.downcase == locale_part }.first
      self.ct_object.locale = locale.code
      self.ct_object.try(:image_url, params) if self.ct_object.file.present?
    end

    class << self

      # Gets a collection of assets.
      # Takes space object.
      # Returns a Contentful::Management::Array of Contentful::Management::Asset.
      def items(space)
        space.assets.all
      end

      # Gets a specific asset.
      # Takesspace and id asset.
      # Returns a Contentful::Management::Asset.
      def item(space, id)
        space.assets.find(id)
      end

    end

    private

    # Create localised File object and removes not needed parameters to create Asset.
    def transform_file_parameters(params)
      locales.each do |locale|
        locale = FileWithLocale.new(self, locale, params)

        params.merge!(locale.param_name(:file) => build_file(locale)) if locale.file_url?

        params.delete(locale.param_name(:file_type))
        params.delete(locale.param_name(:file_url))
      end
    end

    # Set localised file instance variable
    def set_files_instance_variables
      locales.each do |locale|
        locale = FileWithLocale.new(self, locale, {})
        instance_variable_set("@#{locale.param_name(:file)}", build_file(locale))
      end
    end

    # Takes field and locale
    # Returns field with the locale code suffix, e.g name_en_us.
    def localized_field_name(field, locale)
      "#{field.to_s}_#{locale.code.underscore.downcase}"
    end

    # Build localised File object, needed to create / update an Asset.
    def build_file(locale = nil)
      file = Contentful::Management::File.new
      file.properties[:contentType] = locale.file_type
      file.properties[:fileName] = locale.title
      file.properties[:upload] = locale.file_url
      file
    end

    # Set localised instance variable based on Contentful Asset attributes.
    def set_instance_variable(field_name, locale, params, field)
      instance_variable_set("@#{field_name}", params[locale.code] ? params[locale.code][field] : params[field_name])
    end

    def setup_attributes_for_field_and_locale(field, locale, params)
      setup_attributes_for_field(field, locale, params)
    end

    # Assign parameters to each asset field.
    def assign_parameters_for(asset)
      CONTENTFUL_FIELDS.each do |field|
        field_params = locales.each_with_object({}) do |locale, field_params|
          field_name = localized_field_name(field, locale)
          field_params[locale.code] = send(field_name) if respond_to? field_name
        end
        asset.send("#{field}_with_locales=", field_params)
      end
    end
  end
end