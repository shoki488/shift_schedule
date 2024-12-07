Rails.application.routes.draw do
  get 'shift_preferences/create'
  get 'shift_preferences/update'
  get 'shift_preferences/index'
  root 'top#index'
  devise_for :users, controllers: {
    sessions: "users/sessions",
    registrations: "users/registrations"
  }
  devise_scope :user do
    get 'users/guest_sign_in', to: 'users/sessions#guest_sign_in'
    get '/users/sign_out' => 'devise/sessions#destroy'
    get '/users/edit' => 'devise/sregistrations#edit'
  end

  namespace :users do
    resource :account, only: [:show]
  end

  resources :users, only: [:index, :show] do
    member do
      get :favorite
    end
  end

  resources :shifts do
    resource :favorite, only: [:create, :destroy]
  end

  resources :shift_preferences

  get 'question', to: 'question#index'
  get "search", to: 'searches#search'
end
