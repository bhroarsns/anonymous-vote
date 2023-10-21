class Ballot < ApplicationRecord
  # Ballot is the proxy of voter. Ballot is responsible for delivering emails with link to vote to voters,
  # authenticating voters, saving vote choices.

  belongs_to :voting
  validates :voter, presence: true, uniqueness: {scope: :voting_id}

  # use bcrypt to activate :authenticate
  has_secure_password

  def valid?
    self.exp && (self.exp < Time.current)
  end

  # Algorithm for generating password is cupsuled because it's subject to change
  def self.create_password
    SecureRandom.alphanumeric(30)
  end
end
