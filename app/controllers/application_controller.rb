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

  def find_space
    @space = Contentful::Management::Space.find(@settings.space_id)
  end

end
