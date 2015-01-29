CmaDemoApp::Application.routes.draw do

  resource :settings, except: [:show, :index, :delete]

  resources :categories, except: [:show] do
    get :toggle_status, on: :member
  end
  resources :posts do
    get :toggle_status, on: :member
  end

  resources :images, except: [:show] do
    get :toggle_status, on: :member
  end

  root to: 'posts#index'

end
