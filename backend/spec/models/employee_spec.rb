require "rails_helper"

RSpec.describe Employee, type: :model do
  subject { build(:employee) }

  it "has a valid factory" do
    expect(subject).to be_valid
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:full_name) }
    it { is_expected.to validate_presence_of(:job_title) }
    it { is_expected.to validate_presence_of(:department) }
    it { is_expected.to validate_presence_of(:country) }
    it { is_expected.to validate_presence_of(:hired_on) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
    it { is_expected.to validate_inclusion_of(:status).in_array(%w[active terminated]) }
    it { is_expected.to validate_inclusion_of(:currency).in_array(%w[INR USD GBP EUR]) }

    it do
      is_expected.to validate_numericality_of(:salary_cents)
        .only_integer.is_greater_than(0)
    end

    it "rejects an invalid email format" do
      subject.email = "not-an-email"
      expect(subject).not_to be_valid
    end
  end
end
