Rails Example Application
=============

## Description
Sample Rails app to demonstrate the content creation using the [Content Management API RubyGem](https://github.com/contentful/contentful-management.rb).

## Installation

Clone the repository and run

``` shell
bundle install
```

## Usage
Run the application with ```bundle exec rails server``` and open ```http://0.0.0.0:3000/``` in your browser.
The first time you use the application, you will be asked to enter your Contentful ```ACCESS_TOKEN``` and ```ORGANIZATION_ID```.

Once you save your credentials the app will create a space called "CMA Rails App Demo" and setup the ```Post```, ```Category``` content types

Your credentials will be stored in the settings table in a locale SQLite database.


## Contentful module

#### Entity
Initializes objects of Entry type.
Classes that operate on Contentful::Management::Entry objects inherit from it.

Example
``` ruby
class Category < Contentful::Entity

  content_type :category_content_type

end
```

#### Methods
* initialize

Creates localized getters and setters based on the fields of a content type.

Example: two locales with code ```en-US```, ```"de-DE" ``` and a field with API a name: ```title```.
``` ruby
title_en_us
title_de_de
```

* content_type

Gets ID of the content type that you referring to. It helps to find a specified content type and is useful for filtering entries.

* locales

Returns the locales that are available for the space.

* has_one

To declare an association to other entries. The model defines the relationship through the name of 'API' field.

For example, if the post content type has a ```Link field``` with the api_name ```category```

``` ruby
class Post < Contentful::Entity

  content_type :post_content_type

  has_one :category

end
```

In the views, you an return the name of a linked Entry like this:

``` ruby
= link_to post.category(@space).name
```

* all(space)

This method returns all objects for your space. All created objects are cached by the [APICache](https://github.com/mloughran/api_cache) Gem.

* find(space, id)

Returns contentful object.

* build(ct_object, space)

Initialize an entry object from the API.

#### Asset

This class inherits from Entity and represents the asset content type. Classes that operate on Contentful::Management::Asset objects inherit from it.


``` ruby
class Image < Contentful::Asset

end
```

## Helpers

#### contentful_form_for

Generates forms to create and edit entries and assets. It generates only fields that are localized.

#### published_object(object)
Checks status of an entry object.

#### get_image
Display the image of a linked asset. You can specify parameters, which will return a resized version the image.
