Rails.application.routes.draw do
  root 'top#index'
  devise_for :users, controllers: {
    sessions: "users/sessions",
    registrations: "users/registrations"
  }
  devise_scope :user do
    get 'users/guest_sign_in', to: 'users/sessions#guest_sign_in'
    get '/users/sign_out' => 'devise/sessions#destroy'
    get '/users/edit' => 'devise/sessions#edit'
  
    namespace 'users' do 
      resource :account, only: [:show]
    end
    get 'users/index'
    get 'users/account'
    get 'shifts/index'
  end
    resources :shifts
    get 'question', to: 'question#index'
end
