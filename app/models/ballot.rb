class Ballot < ApplicationRecord
  # Ballot is the proxy of voter. Ballot is responsible for authenticating voters, saving vote choices.

  # Attributes
  #   :voting_id => voting which this ballot belongs
  #   :voter => voter's email address
  #   :password_digest => hashed password generated by bcrypt
  #   :choice => if not voted it becomes nil
  #   :exp => expiration date of the password [nil when issued(created)] [set when delivered]
  #   :delivered => if invitation or vote link is delivered to the voter by the owner
  #   :delete_requested => if delete of ballot is requested by voter [set to false when delivered/redelivered]

  # for email validation
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  belongs_to :voting

  validates :voter, presence: true, uniqueness: {scope: :voting_id}, format: { with: VALID_EMAIL_REGEX }
  # value false is invalid when presence: true is set
  validates :delivered, inclusion: [true, false]
  validates :delete_requested, inclusion: [true, false]

  # Set random uuid
  before_create :set_uuid

  # use bcrypt to activate :authenticate
  has_secure_password

  # Renew password every time the ballot is sent via email.
  def renew_password(exp)
    new_pass = Ballot.create_password
    self.update(password: new_pass, exp: exp, delivered: true, delete_requested: false)
    self.save
    { address: self.voter, password: new_pass }
  end

  ## don't need to implement :authenticate by hand because has_secure_password activated
  # def authenticate
  # end

  def expired?
    !self.exp || (self.exp < Time.current)
  end

  # Algorithm for generating password is cupsuled because it's subject to change
  def self.create_password
    SecureRandom.alphanumeric(40)
  end

  private
    def set_uuid 
      while self.id.blank? || Voting.find_by(id: self.id).present? do
        self.id = SecureRandom.uuid
      end
    end
end
