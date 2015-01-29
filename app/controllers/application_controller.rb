class ApplicationController < ActionController::Base

  protect_from_forgery with: :exception
  skip_before_action :verify_authenticity_token

  before_action :initialize_contentful_client
  before_action :check_setup

  private

  def initialize_contentful_client
    @settings = Settings.all.first
    @settings.try(:initialize_contentful_client)
  end

  def check_setup
    redirect_to new_settings_path unless @settings
  end

  def publish_object(object)
    object.ct_object.publish
    object.ct_object.published? ? 'Successfully published!' : "Validation Error - cannot publish object with ID: #{object.id}!"
  end

  def unpublish_object(object)
    object.ct_object.unpublish
    'Successfully unpublished!'
  end

  def delete_from_cache_while_edit(object, entity_id)
    APICache.delete "#{object.ct_type}_#{entity_id}"
  end

  def find_space
    case params[:action]
      when 'edit', 'update'
        APICache.delete('space_cache_key')
        @space = Contentful::Management::Space.find(@settings.space_id)
      else
        @space = APICache.get('space_cache_key', period: 0) do
          Contentful::Management::Space.find(@settings.space_id)
        end
    end
  end
end
