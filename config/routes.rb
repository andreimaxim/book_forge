Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Health check endpoint with database status
  get "health" => "health#show", as: :health

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "dashboard#index"

  # Dashboard namespace (activity timeline feed)
  namespace :dashboard do
    resources :activities, only: [ :index ]
  end

  # Core entity resources
  resources :authors do
    resources :representations, only: [ :create, :update, :destroy ]
  end
  resources :publishers
  resources :agents do
    resources :representations, only: [ :create, :update, :destroy ]
  end
  resources :prospects do
    member do
      post :convert
      patch :decline
    end
  end
  resources :books
  resources :deals

  # Notes (polymorphic, for all notable entities)
  resources :notes, only: [ :show, :create, :edit, :update, :destroy ]

  # Global search
  get "search", to: "search#index", as: :search

  # Activities (for viewing activity history)
  resources :activities, only: [ :index ]

  # Design system test routes (only in test/development)
  if Rails.env.test? || Rails.env.development?
    get "design_system_test/flash" => "design_system_test#flash_test", as: :design_system_test_flash
    get "design_system_test/form" => "design_system_test#form_test", as: :design_system_test_form
    post "design_system_test/form" => "design_system_test#form_submit"
    get "design_system_test/button" => "design_system_test#button_test", as: :design_system_test_button
    post "design_system_test/button" => "design_system_test#button_submit", as: :design_system_test_button_submit

    # Stimulus controller test pages
    get "stimulus_test/form_validation" => "stimulus_test#form_validation", as: :stimulus_test_form_validation
    post "stimulus_test/form_validation" => "stimulus_test#form_validation_submit"
    get "stimulus_test/auto_save" => "stimulus_test#auto_save", as: :stimulus_test_auto_save
    post "stimulus_test/auto_save" => "stimulus_test#auto_save_submit"
    get "stimulus_test/dropdown" => "stimulus_test#dropdown", as: :stimulus_test_dropdown
    get "stimulus_test/clipboard" => "stimulus_test#clipboard", as: :stimulus_test_clipboard
    get "stimulus_test/character_count" => "stimulus_test#character_count", as: :stimulus_test_character_count
    get "stimulus_test/filter" => "stimulus_test#filter", as: :stimulus_test_filter
    get "stimulus_test/sortable" => "stimulus_test#sortable", as: :stimulus_test_sortable
    post "stimulus_test/sortable" => "stimulus_test#sortable_update"
    get "stimulus_test/toast" => "stimulus_test#toast", as: :stimulus_test_toast
  end
end
