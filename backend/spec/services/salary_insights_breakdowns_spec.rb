require "rails_helper"

RSpec.describe SalaryInsights do
  subject(:insights) { described_class.new }

  describe "#by_department" do
    before do
      create(:employee, department: "Engineering", currency: "INR", salary_cents: 10_000)
      create(:employee, department: "Engineering", currency: "INR", salary_cents: 30_000)
      create(:employee, department: "Sales", currency: "USD", salary_cents: 50_000)
      create(:employee, department: "Sales", currency: "USD", salary_cents: 70_000, status: "terminated")
    end

    it "returns headcount, total payroll and average per department" do
      eng = insights.by_department.find { |r| r[:department] == "Engineering" }

      expect(eng).to include(currency: "INR", headcount: 2, total_payroll: 40_000, avg: 20_000)
    end

    it "ignores terminated employees" do
      sales = insights.by_department.find { |r| r[:department] == "Sales" }

      expect(sales).to include(headcount: 1, total_payroll: 50_000)
    end
  end

  describe "#by_job_title" do
    before do
      create(:employee, country: "India", job_title: "Engineer", salary_cents: 10_000)
      create(:employee, country: "India", job_title: "Engineer", salary_cents: 30_000)
      create(:employee, country: "India", job_title: "Designer", salary_cents: 20_000)
      create(:employee, country: "USA", currency: "USD", job_title: "Engineer", salary_cents: 90_000)
    end

    it "groups by job title for the given country" do
      rows = insights.by_job_title(country: "India")
      eng = rows.find { |r| r[:job_title] == "Engineer" }

      expect(rows.size).to eq(2)
      expect(eng).to include(headcount: 2, min: 10_000, avg: 20_000, max: 30_000)
    end

    it "covers all countries when none is given" do
      expect(insights.by_job_title.size).to eq(3)
    end
  end

  describe "#distribution" do
    before do
      [10_000, 20_000, 30_000, 40_000, 50_000].each do |salary|
        create(:employee, currency: "INR", salary_cents: salary)
      end
    end

    it "splits salaries into equal-width bands" do
      result = insights.distribution(buckets: 2).find { |r| r[:currency] == "INR" }

      expect(result[:bands].map { |b| b[:count] }).to eq([2, 3])
      expect(result[:bands].first).to include(from: 10_000, to: 30_000)
    end

    it "never loses an employee" do
      result = insights.distribution(buckets: 3).find { |r| r[:currency] == "INR" }

      expect(result[:bands].sum { |b| b[:count] }).to eq(5)
    end
  end
end
