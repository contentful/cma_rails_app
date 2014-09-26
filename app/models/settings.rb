class Settings < ActiveRecord::Base

  validates :access_token, :organization_id, presence: true

  def setup
    initialize_contentful_client
    space = create_space(organization_id)
    create_locales(space)
    create_category_content_type(space)
    create_post_content_type(space)
    update_column(:space_id, space.id)
  end

  def initialize_contentful_client
    Contentful::Management::Client.new(access_token)
  end

  private

  def create_space(organization_id)
    Contentful::Management::Space.create(name: 'CMA Demo Rails App', organization_id: organization_id)
  end

  def create_locales(space)
    space.locales.create(name: 'English', code: 'en-US')
    space.locales.create(name: 'German', code: 'de-DE')
  end

  def create_category_content_type(space)
    category_type = space.content_types.create(id: 'category_content_type', name: 'Category')
    category_type.fields.create(id: 'name', name: 'Name', type: 'Text', localized: true)
    category_type.fields.create(id: 'description', name: 'Description', type: 'Text', localized: true)
    category_type.update(displayField: 'name')
    category_type.activate
  end

  def create_post_content_type(space)
    post_type = space.content_types.create(id: 'post_content_type', name: 'Post')
    post_type.fields.create(id: 'title', name: 'Title', type: 'Text', localized: true)
    post_type.fields.create(id: 'author', name: 'Author', type: 'Text', localized: true)
    post_type.fields.create(id: 'body', name: 'Body', type: 'Text', localized: true)
    post_type.fields.create(id: 'title_image', name: 'Title Image', type: 'Link', link_type: 'Asset', localized: true, required: true)
    post_type.fields.create(id: 'second_image', name: 'Second Image', type: 'Link', link_type: 'Asset', localized: true)
    post_type.fields.create(id: 'category', name: 'Category', type: 'Link', link_type: 'Entry', localized: true)

    post_type.update(displayField: 'title')

    post_type.activate
  end

end
