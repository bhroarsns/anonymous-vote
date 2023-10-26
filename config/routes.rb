Rails.application.routes.draw do
  root 'toppage#index'
  get '/mypage', to: "users#mypage"

  devise_for :users

  # :index deactivated because user can see all his/her votings via mypage.
  resources :votings, except: :index do
    member do
      get 'voters'
      post 'issue'
      post 'deliver_all'
    end
  end

  resources :ballots, only: [:create, :update, :destroy] do
    member do
      post 'deliver'
      post 'redeliver'
      post 'deliver_from_owner'
    end
  end

  get '*path', controller: 'application', action: 'render_404'
end
