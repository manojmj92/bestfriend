Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

	match 'auth/:provider/callback', to: 'users#login', as: 'login', via: [:get, :post]
	match 'auth/failure', to: redirect('/'), via: [:get, :post]
	match 'signout', to: 'users#signout', as: 'signout', via: [:get, :post]

	
	get '/', to: 'users#index', as: 'root'
	get '/dashboard', to: 'users#dashboard', as: 'dashboard'
end
