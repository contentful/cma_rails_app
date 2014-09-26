class Post < Contentful::Entity

  content_type :post_content_type

  has_one :category

end