require 'rails_helper'

describe PostsController do

  let!(:settings) { create(:settings) }
  render_views

  it 'index' do
    vcr('post/index') do
      get :index
      expect(response.status).to eq 200
      response.should render_template :index
    end
  end

  it 'new' do
    vcr('post/new') do
      get :new
      expect(response.status).to eq 200
      response.should render_template :new
    end
  end

  it 'create' do
    vcr('post/create') do
      post :create, post: {title_en_us: 'Sport is good for health...',
                           author_en_us: 'Protas',
                           body_en_us: 'Some body',
                           title_image_en_us_id: '4OnNiEyHiow0i2IKWUyE4u',
                           second_image_en_us_id: '25YMjrnn2IUy2u0qUS0aCw',
                           category_en_us: '4edQsVRm8g4UAwqGGwmcWA'}
      expect(response.status).to eq 302
      response.should redirect_to posts_path
    end
  end

  it 'update' do
    vcr('post/update') do
      put :update, id: '4Pd4NpuW1q4GI4qWacamIO', post: {title_en_us: 'Sports',
                                                        author_en_us: 'P. Protas',
                                                        body_en_us: 'body update',
                                                        title_image_en_us_id: '4teeyoy7SUMgmGaiG0YiYW',
                                                        second_image_en_us_id: '2clOr9mxFGUIoOm0i6UeiA'}
      expect(response.status).to eq 302
      response.should redirect_to posts_path
    end
  end

  it 'destroy' do
    vcr('post/destroy') do
      delete :destroy, id: '3b5W5MAuX6gYi0EquAWCas'
      expect(response.status).to eq 302
      response.should redirect_to posts_path
    end
  end

end