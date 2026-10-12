class Employee < ApplicationRecord
  STATUSES = %w[active terminated].freeze
  CURRENCIES = %w[INR USD GBP EUR].freeze
  validates :full_name, :job_title, :department, :country, :hired_on, presence: true
  validates :email, presence: true,
            uniqueness: { case_sensitive: false },
            format: {  with: URI::MailTo::EMAIL_REGEXP }
  validates :currency, inclusion: { in: CURRENCIES }
  validates :status, inclusion: { in: STATUSES }
  validates :salary_cents, numericality: { only_integer: true, greater_than: 0 }
end
