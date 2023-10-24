class BallotPolicy < ApplicationPolicy
  def create?
    user
  end

  def destroy?
    owner_signed_in?
  end

  def deliver_from_owner?
    owner_signed_in?
  end

  private
    def owner_signed_in?
      user == record.voting.user
    end
end