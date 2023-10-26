class Voting < ApplicationRecord
  # Voting is responsible for issuing ballots, validating vote choice, counting votes.
  belongs_to :user
  has_many :ballots, dependent: :destroy

  # Set random uuid as voting id to hide from outsider.
  before_create :set_uuid

  validates :title, presence: true
  validates :choices, presence: true
  validates :start, comparison: { less_than: :deadline }
  validates :deadline, comparison: { greater_than: Time.current }

  # just in case
  validate :cannot_change_choices_after_start, on: :update
  validate :cannot_change_mode_when_delivered_exist, on: :update

  # on issuing ballots

  def issue_single_ballot(voter)
    self.ballots.create!(voter: voter, password: Ballot.create_password)
  end

  def issue_ballots(file)
    CSV.foreach(file.path) do |row|
      self.ballots.create!(voter: row[0], password: Ballot.create_password)
    end
  end


  # on delivery by owner

  def exp_at_delivery
    if self.mode == "default"
      self.deadline
    end
  end


  # on getting password or redelivery

  # instance method because users can set this value in the future.
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


  # on vote

  def get_ballot(params)
    # Check if given voter is assigned to this voting
    ballot = self.ballots.find_by(voter: params[:voter])
    
    # Authentication is done at this point to prohibit attackers from getting information about assigned voter
    ballot && ballot.authenticate(params[:password])
  end

  def get_choices
    self.choices.split("\n")
  end


  # voting config change limitation

  def disable_mode_select?
    self.delivered_exist?
  end

  def disable_choices_change?
    self.delivered_exist? && (self.start < Time.current)
  end

  def report_change_on_start_and_deadline
    self.delivered_exist? && (Time.current < self.deadline)
  end

  def report_change_on_title_and_description
    self.delivered_exist? && (self.status == "opened")
  end

  def saved_changes_to_report
    changes = self.saved_changes
    result = {}
    if report_change_on_start_and_deadline
      if changes[:start]
        result[:start] = changes[:start]
      end
      if changes[:deadline]
        result[:deadline] = changes[:deadline]
      end
    end
    if report_change_on_title_and_description
      if changes[:start]
        result[:start] = changes[:start]
      end
      if changes[:description]
        result[:description] = changes[:description]
      end
    end
    result
  end

  
  # get current state of this voting

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


  def self.modes
    [["デフォルト", "default"], ["セキュリティ", "security"]]
  end

  private
    def set_uuid 
      while self.id.blank? || Voting.find_by(id: self.id).present? do
        self.id = SecureRandom.uuid
      end
    end

    def delivered_exist?
      self.ballots.exists?(delivered: true)
    end

    def cannot_change_choices_after_start
      if self.disable_choices_change? && self.will_save_change_to_choices?
        errors.add(:choices, "投票開始後, リンク送信済みの参加者がいる場合は選択肢を変更できません.")
      end
    end

    def cannot_change_mode_when_delivered_exist
      if self.disable_mode_select? && self.will_save_change_to_mode?
        errors.add(:mode, "リンク送信済みの参加者がいる場合, モードは変更できません.")
      end
    end
end
