class Voting < ApplicationRecord
  # Voting is responsible for issuing ballots, validating vote choice, counting votes.
  belongs_to :user
  has_many :ballots, dependent: :destroy

  # Set random uuid as voting id to hide from outsider.
  before_create :set_uuid

  def issue_single_ballot(voter)
    self.ballots.create!(voter: voter, password: Ballot.create_password)
  end

  def issue_ballots(file)
    CSV.foreach(file.path) do |row|
      self.ballots.create!(voter: row[0], password: Ballot.create_password)
    end
  end

  def get_ballot(params)
    # Check if given voter is assigned to this voting
    ballot = self.ballots.find_by(voter: params[:voter])
    
    # Authentication is done at this point to prohibit attackers from getting information about assigned voter
    ballot && ballot.authenticate(params[:password])
  end

  def get_choices
    self.choices.split("\n")
  end

  def self.modes
    [["デフォルト", "default"], ["セキュリティ", "security"]]
  end

  def exp_at_delivery
    if self.mode == "default"
      self.deadline
    end
  end

  def exp_at_vote
    if self.mode == "default"
      self.deadline
    elsif self.mode == "security"
      Time.current + 3.minutes
    end
  end

  def closed?
    self.deadline < Time.current
  end

  def count_not_delivered
    self.ballots.where(is_delivered: nil).count
  end

  def count_votes
    # Voter (and also owner) should not be able to see the vote counts until the deadline
    if self.deadline < Time.current
      self.ballots.where(is_delivered: true).group(:choice).count
    end
  end

  private
    def set_uuid 
      while self.id.blank? || Voting.find_by(id: self.id).present? do
        self.id = SecureRandom.uuid
      end
    end
end
