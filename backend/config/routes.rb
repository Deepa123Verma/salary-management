Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  namespace :api do
    namespace :v1 do
      resources :employees
      get "insights/by_country", to: "insights#by_country"
      get "insights/by_department", to: "insights#by_department"
      get "insights/by_job_title",  to: "insights#by_job_title"
      get "insights/distribution",  to: "insights#distribution"
    end
  end

  # Defines the root path route ("/")
  # root "posts#index"
end
