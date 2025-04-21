Rails.application.routes.draw do
  resources :wallets, only: [] do
    member do
      post :deposit
      post :withdraw
    end
  end

  resources :users do
      resources :transactions, only: [] do
        collection do
          post :transfer_to
        end
      end
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
