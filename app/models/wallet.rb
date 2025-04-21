class Wallet < ApplicationRecord
  belongs_to :user

  validates :balance, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :name, presence: true, length: { maximum: 255 }

  has_many :transactions, dependent: :restrict_with_error
end
