require "rails_helper"

RSpec.describe "Insights API", type: :request do
  let(:body) { JSON.parse(response.body) }

  describe "GET /api/v1/insights/by_country" do
    before do
      create(:employee, country: "India", currency: "INR", salary_cents: 10_000)
      create(:employee, country: "India", currency: "INR", salary_cents: 30_000)
      create(:employee, country: "USA", currency: "USD", salary_cents: 50_000)
    end

    it "returns salary stats per country" do
      get "/api/v1/insights/by_country"

      expect(response).to have_http_status(:ok)
      expect(body["data"].size).to eq(2)

      india = body["data"].find { |r| r["country"] == "India" }
      expect(india).to include(
        "currency" => "INR", "headcount" => 2,
        "min" => 10_000, "avg" => 20_000, "median" => 20_000, "max" => 30_000
      )
    end

    it "returns an empty list when there are no employees" do
      Employee.delete_all
      get "/api/v1/insights/by_country"

      expect(body["data"]).to eq([])
    end
  end
end
