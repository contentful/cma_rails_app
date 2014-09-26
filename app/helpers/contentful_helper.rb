module ContentfulHelper

  def contentful_form_for(object, *args, &block)
    options = args.extract_options!
    new = object.ct_object.nil?
    options.merge!(url: {action: new ? :create : :update})
    options.merge!(method: new ? :post : :put)

    form_for(object, *(args << options), &block)
  end

  def published_object(object)
    object.ct_object.published? ? ' Unpublish ' : ' Publish '
  end

  def get_image(object)
    @images.each do |image|
      if image.id == object && object.present?
        return image.image_url(h: 250, w: 200)
      end
    end
    nil
  end

  def convert_boolean_value(value)
    value ? 'Yes' : 'No'
  end

end