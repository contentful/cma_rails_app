require 'rails_helper'

describe CategoriesController do

  let!(:settings) { create(:settings) }
  render_views

  it 'index' do
    vcr('category/index') do
      get :index
      expect(response.status).to eq 200
      response.should render_template :index
    end
  end

  it 'new' do
    vcr('category/new') do
      get :new
      expect(response.status).to eq 200
      response.should render_template :new
    end
  end

  it 'create' do
    vcr('category/create') do
      post :create, category: {name_en_us: 'Sports EN', name_de_de: 'Sport DE', name_pl_pl: 'Sport PL',
                               description_en_us: 'Sports category EN', description_de_de: 'Sports category EN', description_pl_pl: 'Sports category EN'}
      expect(response.status).to eq 302
      response.should redirect_to categories_path
    end
  end

  it 'update' do
    vcr('category/update') do
      put :update, id: '14498XWGiIwQyOAmKq2YeO', category: {name_en_us: 'Sports EN', name_de_de: 'Sport DE', name_pl_pl: 'Sport PL',
                                                            description_en_us: 'Sports category EN'}
      expect(response.status).to eq 302
      response.should redirect_to categories_path
    end
  end

  it 'destroy' do
    vcr('category/destroy') do
      delete :destroy, id: '2TfOVAXdVYkMYuAsWsW8EW'
      expect(response.status).to eq 302
      response.should redirect_to categories_path
    end
  end

end