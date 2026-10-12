FactoryBot.define do
  factory :employee do
    sequence(:full_name) { |n| "Employee #{n}" }
    sequence(:email) { |n| "employee#{n}@acme.com" }
    job_title { "Software Engineer" }
    department { "Engineering" }
    country { "India" }
    currency { "INR" }
    salary_cents { 120_000_000 }
    hired_on { Date.new(2022, 1, 15) }
    status { "active" }
  end
end
