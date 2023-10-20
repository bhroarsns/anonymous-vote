class Ballot < ApplicationRecord
  belongs_to :voting

  # use bcrypt
  has_secure_password

  def self.create_password
    SecureRandom.alphanumeric(30)
  end
end
