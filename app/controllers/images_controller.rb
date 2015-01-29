class ImagesController < ApplicationController

  before_action :find_space
  before_action :find_asset, only: [:edit, :update, :destroy, :toggle_status]

  def index
    @images = Image.all(@space)
  end

  def new
    @image = Image.new({space: @space})
  end

  def create
    @image = Image.new(params[:image].merge(space: @space))
    if @image.save(@space)
      redirect_to images_path, notice: 'Successfully created!'
    else
      redirect_to images_path, notice: "#{display_errors}"
    end
  end

  def edit
  end

  def update
    @image.update(params[:image])
    redirect_to images_path
  end

  def destroy
    @image.destroy
    redirect_to images_path, notice: 'Successfully deleted!'
  end

  def toggle_status
    msg = @image.ct_object.published? ? unpublish_object(@image) : publish_object(@image)
    redirect_to images_path, notice: msg
  end

  private

  def find_asset
    @image = Image.find(@space, params[:id])
  end

  def display_errors
    @image.errors_contentful.join(', ')
  end

end
