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
  scope :in_country, ->(country) { country.present? ? where(country: country) : all }
  scope :with_status, ->(status) {status.present? ? where(status: status) : all }
  scope :in_department, ->(dept) { dept.present? ? where(department: dept) : all }
  scope :search, lambda {|q|
 if q.present?
    where("full_name LIKE :q OR email LIKE :q OR job_title LIKE :q",q: "%#{q}%")
 else
  all
 end
  }
end
