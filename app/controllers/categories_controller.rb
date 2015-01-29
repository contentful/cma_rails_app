class CategoriesController < ApplicationController

  before_action :find_space
  before_action :find_category, only: [:edit, :toggle_status, :update, :destroy]
  before_action :delete_from_cache, only: [:edit]

  def index
    @categories = Category.all(@space)
  end

  def new
    @category = Category.new({space: @space})
  end

  def create
    @category = Category.new(params[:category].merge(space: @space))
    if @category.save(@space)
      redirect_to categories_path, notice: 'Successfully created!'
    else
      redirect_to new_category_path, notice: "#{display_errors}"
    end
  end

  def edit
  end

  def toggle_status
    msg = @category.ct_object.published? ? unpublish_object(@category) : publish_object(@category)
    redirect_to categories_path, notice: msg
  end

  def update
    if @category.update(params[:category])
      redirect_to categories_path, notice: 'Successfully updated!'
    else
      redirect_to edit_category_path(params[:id]), notice: "#{display_errors}"
    end
  end

  def destroy
    @category.destroy
    redirect_to categories_path, notice: 'Successfully deleted!'
  end

  def delete_from_cache
    delete_from_cache_while_edit(@category, params[:id])
  end

  private

  def find_category
    @category = Category.find(@space, params[:id])
  end

  def display_errors
    @category.errors_contentful.join(', ')
  end

end