class PostsController < ApplicationController

  before_action :find_space
  before_action :find_post, only: [:edit, :show, :update, :toggle_status, :destroy]
  before_action :find_related_objects, only: [:new, :edit, :show]
  before_action :delete_from_cache, only: [:edit]

  def index
    @posts = Post.all(@space)
  end

  def new
    @post = Post.new({space: @space})
  end

  def show
  end

  def create
    post = Post.new(post_params.merge({space: @space}))
    post.save(@space)
    redirect_to posts_path
  end

  def edit

  end

  def toggle_status
    msg = @post.ct_object.published? ? unpublish_object(@post) : publish_object(@post)
    redirect_to posts_path, notice: msg
  end

  def update
    if @post.update(post_params)
      redirect_to posts_path, notice: 'Successfully updated!'
    else
      redirect_to edit_category_path(params[:id]), notice: "#{display_errors(@post)}"
    end
  end

  def destroy
    @post.destroy
    redirect_to posts_path, notice: 'Successfully deleted!'
  end

  private

  def delete_from_cache
    delete_from_cache_while_edit(@post, params[:id])
  end

  def find_post
    @post = Post.find(@space, params[:id])
  end

  def post_params
    find_categories
    find_images
    params[:post]
  end

  def find_images
    title_en_id = params[:post].delete(:title_image_en_us_id)
    title_en = title_en_id.present? ? Image.find(@space, title_en_id).ct_object : nil
    params[:post].merge!(title_image_en_us_id: title_en) if title_en
    title_de_id = params[:post].delete(:title_image_de_de_id)
    title_de = title_de_id.present? ? Image.find(@space, title_de_id).ct_object : nil
    params[:post].merge!(title_image_de_de_id: title_de) if title_de
    title_pl_id = params[:post].delete(:title_image_pl_pl_id)
    title_pl = title_pl_id.present? ? Image.find(@space, title_pl_id).ct_object : nil
    params[:post].merge!(title_image_pl_pl_id: title_pl) if title_pl

    second_title_en_id = params[:post].delete(:second_image_en_us_id)
    second_title_en = second_title_en_id.present? ? Image.find(@space, second_title_en_id).ct_object : nil
    params[:post].merge!(second_image_en_us_id: second_title_en) if second_title_en
    second_title_de_id = params[:post].delete(:second_image_de_de_id)
    second_title_de = second_title_de_id.present? ? Image.find(@space, second_title_de_id).ct_object : nil
    params[:post].merge!(second_image_de_de_id: second_title_de) if second_title_de
    second_title_pl_id = params[:post].delete(:second_image_pl_pl_id)
    second_title_pl = second_title_pl_id.present? ? Image.find(@space, second_title_pl_id).ct_object : nil
    params[:post].merge!(second_image_pl_pl_ix: second_title_pl) if second_title_pl
  end

  def find_categories
    category_en_id = params[:post].delete(:category_en_us_id)
    category_en = category_en_id.present? ? Category.find(@space, category_en_id).ct_object : nil
    params[:post].merge!(category_en_us_id: category_en) if category_en
    category_de_id = params[:post].delete(:category_de_de_id)
    category_de = category_de_id.present? ? Category.find(@space, category_de_id).ct_object : nil
    params[:post].merge!(category_de_de_id: category_de) if category_de
    category_pl_id = params[:post].delete(:category_pl_pl_id)
    category_pl = category_pl_id.present? ? Category.find(@space, category_pl_id).ct_object : nil
    params[:post].merge!(category_pl_pl_id: category_pl) if category_pl
  end

  def find_related_objects
    @images = Image.all(@space)
    @categories = Category.all(@space)
  end

  def display_errors
    @post.errors_contentful.join(', ')
  end

end