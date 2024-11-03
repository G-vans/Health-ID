Rails.application.routes.draw do
  devise_for :companies
  devise_for :patients
  root 'welcome#index'
  resources :access_requests, only: [:index, :new, :create]
  resources :companies do
    member do
      get :dashboard
      post :request_access
    end
  end
  resources :patients do 
    member do
      get :dashboard
    end
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
