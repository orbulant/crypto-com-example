class User < ApplicationRecord
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }, uniqueness: { case_sensitive: false }

  before_save :downcase_email

  has_one :wallet, dependent: :destroy

  def as_json(options = {})
    super(options.merge(include: :wallet)) # This shouldn't be here, i included it in so that we can easily get the wallet details
  end

  private

  def downcase_email
    self.email = email.downcase if email.present?
  end
end
