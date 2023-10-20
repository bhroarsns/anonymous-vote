Rails.application.routes.draw do
  root 'toppage#index'
  get '/mypage', to: "users#mypage"

  devise_for :users
end
