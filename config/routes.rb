Rails.application.routes.draw do
  root 'lexical_analyzers#index'
  resources :lexical_analyzers
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
