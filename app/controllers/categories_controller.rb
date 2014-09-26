class CategoriesController < ApplicationController

  before_action :find_space
  before_action :find_category, only: [:edit,:toggle_status, :update, :destroy]

  def index
    @categories = Category.all(@space)
  end

  def new
    @category = Category.new({space: @space})
  end

  def create
    category = Category.new(params[:category].merge(space: @space))
    category.save(@space)
    redirect_to categories_path
  end

  def edit
  end

  def toggle_status
    @category.ct_object.publish
    msg = if @category.ct_object.published?
            'Successfully published!'
          else
            'Validation Error - cannot publish this category!'
          end
    redirect_to categories_path, notice: msg
  end

  def update
    @category.update(params[:category])
    redirect_to categories_path
  end

  def destroy
    @category.destroy
    redirect_to categories_path
  end

  private

  def find_category
    @category = Category.find(@space, params[:id])
  end

end