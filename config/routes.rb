Rails.application.routes.draw do
  root "dashboard#index"

  resources :customers, only: [:show] do
    member do
      get  :orders
      get  :export_orders
      get  :export_invoices
      get  :export_interactions
    end
  end

  resources :sales_orders, only: [] do
    patch :release, on: :member
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
