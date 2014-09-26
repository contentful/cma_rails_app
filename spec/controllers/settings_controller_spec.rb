require 'rails_helper'

describe SettingsController do

  let!(:settings) { create(:settings) }

  it 'create' do
    vcr('settings/create') do
      post :create, settings: {access_token: '<ACCESS_TOKEN>',
                               organization_id: '<ORGANIZATION_ID>'}
      expect(response.status).to eq 302
      response.should redirect_to posts_path
    end
  end

  it 'new' do
    get :new
    expect(response.status).to eq 200
    response.should render_template :new
  end

  it 'update' do
    put :update, settings: {access_token: 'ACCESS_TOKEN'}
    expect(response.status).to eq 302
    response.should redirect_to posts_path
  end

end