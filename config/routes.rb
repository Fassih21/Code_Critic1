Rails.application.routes.draw do
  devise_for :users

  resources :projects do
    resources :code_files, shallow: true do
      resource :review, shallow: true do
        resources :comments, only: [:create], shallow: true
      end
    end
  end

  root "projects#index"

  get "up" => "rails/health#show", as: :rails_health_check
end