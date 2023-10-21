Rails.application.routes.draw do
  root 'toppage#index'
  get '/mypage', to: "users#mypage"

  devise_for :users

  # :index deactivated because user can see all his/her votings via mypage.
  resources :votings, except: :index do
    member do
      post 'issue'
      post 'deliver_all'
    end
  end

  resources :ballots do
    member do
      post 'deliver'
    end
  end

end
