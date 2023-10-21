class VotingPolicy < ApplicationPolicy
  def new?
    user
  end

  def create?
    user
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

  def deliver_all?
    owner_signed_in?
  end

  private
    def owner_signed_in?
      user == record.user
    end
end