class SettingsController < ApplicationController

  skip_before_action :check_setup, only: [:new, :create]

  def new
    @settings = Settings.new
  end

  def create
    @settings = Settings.new(params.require(:settings).permit(:access_token, :organization_id))
    if @settings.save
      @settings.setup
      redirect_to posts_path
    else
      flash[:error] = @settings.errors.full_messages.join('<br/>')
      render :new
    end
  end

  def edit
  end

  def update
    if @settings.update(params.require(:settings).permit(:access_token))
      redirect_to posts_path
    else
      flash[:error] = @settings.errors.full_messages.join('<br/>')
      render :edit
    end
  end

end
