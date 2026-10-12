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

  describe "scopes" do
    let!(:india_eng) { create(:employee, full_name: "Asha Rao", country: "India", department: "Engineering", job_title: "Software Engineer") }
    let!(:us_sales)  { create(:employee, full_name: "John Smith", country: "USA", currency: "USD", department: "Sales", job_title: "Account Executive") }
    let!(:old_emp)   { create(:employee, full_name: "Ravi Kumar", country: "India", status: "terminated") }

    describe ".in_country" do
      it "filters by country" do
        expect(Employee.in_country("USA")).to contain_exactly(us_sales)
      end

      it "returns everyone when country is blank" do
        expect(Employee.in_country(nil).count).to eq(3)
      end
    end

    describe ".in_department" do
      it "filters by department" do
        expect(Employee.in_department("Sales")).to contain_exactly(us_sales)
      end
    end

    describe ".with_status" do
      it "filters by status" do
        expect(Employee.with_status("terminated")).to contain_exactly(old_emp)
      end
    end

    describe ".search" do
      it "matches name case-insensitively" do
        expect(Employee.search("asha")).to contain_exactly(india_eng)
      end

      it "matches job title" do
        expect(Employee.search("account")).to contain_exactly(us_sales)
      end

      it "returns everyone when query is blank" do
        expect(Employee.search("").count).to eq(3)
      end
    end
  end
end
