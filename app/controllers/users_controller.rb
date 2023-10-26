class UsersController < ApplicationController
  before_action :sign_in_required

  def mypage
    @votings = current_user.votings.order(start: "DESC")
  end
end
