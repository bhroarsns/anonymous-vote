class Ballot < ApplicationRecord
  belongs_to :voting
  validates :voter, presence: true, uniqueness: {scope: :voting_id}

  # use bcrypt
  has_secure_password

  def self.create_password
    SecureRandom.alphanumeric(30)
  end
end
