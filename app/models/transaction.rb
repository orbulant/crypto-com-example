class Transaction < ApplicationRecord
  belongs_to :wallet
  belongs_to :user

  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
