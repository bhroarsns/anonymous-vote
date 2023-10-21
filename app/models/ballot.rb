class Ballot < ApplicationRecord
  # Ballot is the proxy of voter. Ballot is responsible for delivering emails with link to vote to voters,
  # authenticating voters, saving vote choices.

  belongs_to :voting
  validates :voter, presence: true, uniqueness: {scope: :voting_id}

  # use bcrypt
  has_secure_password

  # Algorithm for generating password is cupsuled because it's subject to change
  def self.create_password
    SecureRandom.alphanumeric(30)
  end
end
