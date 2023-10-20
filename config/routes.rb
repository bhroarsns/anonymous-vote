Rails.application.routes.draw do
  root 'toppage#index'

  devise_for :users
end
