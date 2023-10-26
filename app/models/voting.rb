class Voting < ApplicationRecord
  # Voting is responsible for issuing ballots, validating vote choice, counting votes.
  belongs_to :user
  has_many :ballots, dependent: :destroy

  # Set random uuid as voting id to hide from outsider.
  before_create :set_uuid

  validates :title, presence: true
  validates :deadline, comparison: { greater_than: :start }
  validates :deadline, comparison: { greater_than: Time.current }

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

  def security_exp_in_minute
    3
  end

  def exp_at_vote
    case self.mode
    when "default"
      self.deadline
    when "security"
      Time.current + self.security_exp_in_minute.minutes
    end
  end

  def status
    if Time.current < self.start
      "not opened"
    elsif Time.current < self.deadline
      "opened"
    else
      "closed"
    end
  end

  def count_not_delivered
    self.ballots.where(delivered: nil).count
  end

  def count_delete_request
    self.ballots.where(delete_requested: true).count
  end

  def count_votes
    # Voter (and also owner) should not be able to see the vote counts until the deadline
    if self.deadline < Time.current
      self.ballots.where(delivered: true).group(:choice).count
    end
  end

  def delivered_exist
    self.ballots.exists?(delivered: true)
  end

  private
    def set_uuid 
      while self.id.blank? || Voting.find_by(id: self.id).present? do
        self.id = SecureRandom.uuid
      end
    end
end
