class User < ApplicationRecord
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }, uniqueness: { case_sensitive: false }

  before_save :downcase_email

  has_one :wallet, dependent: :destroy

  private

  def downcase_email
    self.email = email.downcase if email.present?
  end
end
