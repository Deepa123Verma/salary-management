require "rails_helper"

RSpec.describe SalaryInsights do
  describe "#by_country" do
    before do
      [10_000, 20_000, 30_000, 40_000].each do |salary|
        create(:employee, country: "India", currency: "INR", salary_cents: salary)
      end
      create(:employee, country: "India", currency: "INR", salary_cents: 99_900, status: "terminated")

      [10_000, 20_000, 60_000].each do |salary|
        create(:employee, country: "USA", currency: "USD", salary_cents: salary)
      end
    end

    let(:rows) { described_class.new.by_country }
    let(:india) { rows.find { |r| r[:country] == "India" } }
    let(:usa)   { rows.find { |r| r[:country] == "USA" } }

    it "returns one row per country" do
      expect(rows.map { |r| r[:country] }).to contain_exactly("India", "USA")
    end

    it "keeps the currency on each row" do
      expect(india[:currency]).to eq("INR")
      expect(usa[:currency]).to eq("USD")
    end

    it "computes min, avg, max and headcount" do
      expect(india).to include(min: 10_000, avg: 25_000, max: 40_000, headcount: 4)
    end

    it "ignores terminated employees" do
      expect(india[:headcount]).to eq(4)
      expect(india[:max]).to eq(40_000)
    end

    it "computes the median for an even number of employees" do
      expect(india[:median]).to eq(25_000)
    end

    it "computes the median for an odd number of employees" do
      expect(usa[:median]).to eq(20_000)
    end
  end
end
