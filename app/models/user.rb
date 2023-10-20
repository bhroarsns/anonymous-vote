class User < ApplicationRecord
  # User is responsible for authenticating voting host.

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :lockable, :timeoutable
  
  has_many :votings, dependent: :destroy
end
