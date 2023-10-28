class User < ApplicationRecord
  # User is responsible for authenticating voting host.
  
  validates :name, presence: true

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :lockable
  
  has_many :votings, dependent: :destroy
end
