class ImagesController < ApplicationController

  before_action :find_space
  before_action :find_asset, only: [:edit, :update, :destroy]

  def index
    @images = Image.all(@space)
  end

  def new
    @image = Image.new({space: @space})
  end

  def create
    asset = Image.new(params[:image].merge(space: @space))
    asset.save(@space)
    redirect_to images_path
  end

  def edit
  end

  def update
    @image.update(params[:image])
    redirect_to images_path
  end

  def destroy
    @image.destroy
    redirect_to images_path
  end

  private

  def find_asset
    @image = Image.find(@space, params[:id])
  end

end
