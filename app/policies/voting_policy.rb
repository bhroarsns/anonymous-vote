class VotingPolicy < ApplicationPolicy
  def new?
    owner_signed_in?
  end

  def create?
    owner_signed_in?
  end

  def edit?
    owner_signed_in?
  end

  def update?
    owner_signed_in?
  end

  def destroy?
    owner_signed_in?
  end

  def issue?
    owner_signed_in?
  end

  private
    def owner_signed_in?
      user && (user.id == record.user_id)
    end
end