Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get '/', to: 'users#index', as: 'root'

	match 'auth/:provider/callback', to: 'users#login', as: 'login', via: [:get, :post]
	match 'auth/failure', to: redirect('/'), via: [:get, :post]
	match 'signout', to: 'users#signout', as: 'signout', via: [:get, :post]

	resources :dashboard, only: [:index]
end
