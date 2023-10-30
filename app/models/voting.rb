class Voting < ApplicationRecord
  # Voting is responsible for issuing ballots, validating vote choice, counting votes.

  # Attributes
  #   :user_id => owner of this voting
  #   :title
  #   :description => insert </br> at the place of \n when displayed.
  #   :choices => allowed choices of this voting [represented as text with \n as a partition]
  #   :start => voters can vote after :start
  #   :deadline => voters can vote before :deadline
  #   :mode => determines the type of link owner can deliver [vote link when default] [invitation link when security]
  #   :config => currently disabled

  belongs_to :user
  has_many :ballots, dependent: :destroy

  # Set random uuid as voting id
  before_create :set_uuid

  validates :title, presence: true
  validates :choices, presence: true
  validates :start, comparison: { less_than: :deadline }
  validates :deadline, comparison: { greater_than: Time.current }
  validates :mode, presence: true, inclusion: { in: %w(default security), message: "モードが正しくありません." }

  validate :changes_in_attribute_allowed, on: :update

  # on issuing ballots

  def issue_new_ballot(voter)
    begin
      self.ballots.create!(voter: voter, password: Ballot.create_password, delivered: false, delete_requested: false)
    rescue => e
      e.record
    end
  end

  def issue_ballots(file)
    succeeded = []
    failed = []
    CSV.foreach(file.path) do |row|
      result = self.issue_new_ballot(row[0])
      if result.errors.any?
        failed << result
      else
        succeeded << result
      end
    end
    {
      succeeded: succeeded,
      failed: failed
    }
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

  def exp_at_redelivery
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

  def choices_array
    self.choices.split("\n")
  end


  # voting config change limitation

  def attr_locks
    {
      title: false,
      description: false,
      choices: false,
      start: self.delivered_exists? && (self.start_in_database < Time.current) ? { message: "は, 投票が始まっているため変更できません." } : false,
      deadline: false,
      mode: self.delivered_exists? ? { message: "は, リンク送信済みの参加者がいるため変更できません." } : false,
    }
  end

  def config_change_reports
    msg = nil
    attrs = []
    if self.delivered_exists?
      msg = "投票開始・終了時刻及びタイトルの変更はリンク送信済みの参加者にメールで通知されます。"
      attrs.append(:start, :deadline, :title)
      if self.started?
        msg = msg + "\nさらに、投票開始後のため、説明・選択肢の変更もリンク送信済みの参加者に通知されます。"
        attrs.append(:description, :choices)
      end
    end
    {
      message: msg,
      attrs: attrs
    }
  end

  def saved_changes_to_report
    changes = self.saved_changes
    attrs_to_report = self.config_change_reports[:attrs]
    result = {}

    attrs_to_report.each do |attr|
      if changes[attr]
        result[attr] = changes[attr]
      end
    end

    result
  end

  
  # get current state of this voting

  def started?
    self.start < Time.current
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
    self.ballots.where(delivered: false).count
  end

  def count_delete_requests
    self.ballots.where(delete_requested: true).count
  end

  def count_votes
    # Voter (and also owner) should not be able to see the vote counts until the deadline
    if self.deadline < Time.current
      self.ballots.where(delete_requested: false, delivered: true).group(:choice).count
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

    def delivered_exists?
      self.ballots.exists?(delivered: true)
    end

    def voted_exists?
      self.ballots.where.not(choice: nil).exists?
    end

    def changes_in_attribute_allowed
      locks = self.attr_locks

      if locks[:title] && self.will_save_change_to_title?
        errors.add(:title, locks[:title][:message])
      end
      if locks[:description] && self.will_save_change_to_description?
        errors.add(:description, locks[:description][:message])
      end
      if locks[:choices] && self.will_save_change_to_choices?
        errors.add(:choices, locks[:choices][:message])
      end
      if locks[:start] && self.will_save_change_to_start?
        errors.add(:start, locks[:start][:message])
      end
      if locks[:deadline] && self.will_save_change_to_deadline?
        errors.add(:deadline, locks[:deadline][:message])
      end
      if locks[:mode] && self.will_save_change_to_mode?
        errors.add(:mode, locks[:mode][:message])
      end
    end
end
