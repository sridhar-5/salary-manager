Rails.application.routes.draw do
  devise_for :admin_users, skip: :all

  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      resource :session, only: %i[create show destroy]
      resource :password, only: :update

      resources :currencies
      resources :countries
      resources :departments
      resources :job_titles
      resources :employment_levels
      resources :job_title_levels
      resources :employees do
        resources :compensation_records, only: %i[index show create update destroy]
      end
      resources :salary_bands
      resources :exchange_rates
    end
  end
end
