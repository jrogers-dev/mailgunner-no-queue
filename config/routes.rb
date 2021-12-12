Rails.application.routes.draw do
  devise_for :users,
    controllers: {
      sessions: 'users/sessions',
      registrations: 'users/registrations'
    }
  get '/mail', to: 'mail#show'
  post '/mail', to: 'mail#create'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
