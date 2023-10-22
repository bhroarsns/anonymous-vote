Rails.application.routes.draw do
  root 'toppage#index'
  get '/mypage', to: "users#mypage"

  devise_for :users

  # :index deactivated because user can see all his/her votings via mypage.
  resources :votings, except: :index do
    member do
      post 'issue'
      post 'deliver_all'
      get 'voters'
    end
  end

  resources :ballots, only: [:create, :update, :destroy] do
    member do
      post 'deliver'
    end
  end

end
