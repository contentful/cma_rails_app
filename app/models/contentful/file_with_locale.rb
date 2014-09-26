module Contentful
  class FileWithLocale

    attr_accessor :object, :locale, :params

    def initialize(object, locale, params={})
      @object, @locale, @params = object, locale, params
    end

    # Returns converted locale code. e.g "en-US =>  en_us".
    def locale_code
      locale.code.underscore.downcase
    end

    # Returns value of file_url.
    def file_url
      value_for(:file_url)
    end

    # Checks if updating objects has added any asset.
    def file_url?
      file_url.present?
    end

    # Returns value of title.
    def title
      value_for(:title)
    end

    # Returns value of file_type.
    def file_type
      value_for(:file_type)
    end

    # Returns value of file.
    def file
      value_for(:file)
    end

    # Takes name of attribute.
    # Returns value from params or form instance.
    def value_for(method)
      name = param_name(method)
      params[name].presence || object.instance_variable_get("@#{name}")
    end

    # Takes attribute name.
    # Returns attribute with the locale code suffix.
    def param_name(method)
      "#{method}_#{locale_code}"
    end
  end
end