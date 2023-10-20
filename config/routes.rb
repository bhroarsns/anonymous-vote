Rails.application.routes.draw do
  resources :votings
  root 'toppage#index'
  get '/mypage', to: "users#mypage"

  devise_for :users
end
