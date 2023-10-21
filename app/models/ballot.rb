class Ballot < ApplicationRecord
  # Ballot is the proxy of voter. Ballot is responsible for authenticating voters, saving vote choices.

  belongs_to :voting
  validates :voter, presence: true, uniqueness: {scope: :voting_id}

  # use bcrypt to activate :authenticate
  has_secure_password

  # Renew password every time the ballot is sent via email.
  def renew_password(exp)
    new_pass = Ballot.create_password
    self.update(password: new_pass, exp: exp)
    self.save
    new_pass
  end

  ## don't need to implement :authenticate by hand because has_secure_password activated
  # def authenticate
  # end

  def expired?
    !self.exp || (self.exp > Time.current)
  end

  # Algorithm for generating password is cupsuled because it's subject to change
  def self.create_password
    SecureRandom.alphanumeric(30)
  end
end
