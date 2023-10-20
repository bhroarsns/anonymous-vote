class Voting < ApplicationRecord
  # Voting is responsible for issuing ballots, validating vote choice, counting votes.
  belongs_to :user

  # Set random uuid as voting id to hide from outsider.
  before_create :set_uuid

  def get_ballot(voter, password)
  end

  def get_choices
    self.choices.split("\n")
  end

  private
    def set_uuid 
      while self.id.blank? || Voting.find_by(id: self.id).present? do
        self.id = SecureRandom.uuid
      end
    end
end
