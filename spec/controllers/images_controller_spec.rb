require 'rails_helper'

describe ImagesController do

  let!(:settings) { create(:settings) }

  render_views

  it 'index' do
    vcr('image/index') do
      get :index
      expect(response.status).to eq 200
      response.should render_template :index
    end
  end

  it 'new' do
    vcr('image/new') do
      get :new
      expect(response.status).to eq 200
      response.should render_template :new
    end
  end

  it 'create' do
    vcr('image/create') do
      post :create,
           image: {
               title_en_us: 'Test name',
               description_en_us: 'Test description',
               file_url_en_us: 'https://upload.wikimedia.org/wikipedia/commons/c/c7/Gasometer_Berlin_Sch%C3%B6neberg_2011.jpg',
               file_type_en_us: 'image/jpeg'
           }
      expect(response.status).to eq 302
    end
  end

  it 'update' do
    vcr('image/update') do
      put :update, id: '6rsv917hReaKM8CyIGSES',
          image: {
              title_en_us: 'Test name',
              description_en_us: 'Test description',
              file_url_en_us: 'https://upload.wikimedia.org/wikipedia/commons/c/c7/Gasometer_Berlin_Sch%C3%B6neberg_2011.jpg',
              file_type_en_us: 'image/jpeg'
          }
      expect(response.status).to eq 302
    end
  end

  it 'destroy' do
    vcr('image/destroy') do
      delete :destroy, id: '6rsv917hReaKM8CyIGSES'
      expect(response.status).to eq 302
      response.should redirect_to images_path
    end
  end

end