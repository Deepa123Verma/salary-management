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

  context "with employees in two departments" do
    before do
      create(:employee, country: "India", department: "Engineering", job_title: "Engineer", salary_cents: 10_000)
      create(:employee, country: "India", department: "Sales", job_title: "Manager", salary_cents: 30_000)
    end

    it "GET by_department returns rows" do
      get "/api/v1/insights/by_department"

      expect(response).to have_http_status(:ok)
      expect(body["data"].map { |r| r["department"] }).to contain_exactly("Engineering", "Sales")
    end

    it "GET by_job_title filters by country" do
      get "/api/v1/insights/by_job_title", params: { country: "India" }

      expect(response).to have_http_status(:ok)
      expect(body["data"].size).to eq(2)
    end

    it "GET distribution returns bands" do
      get "/api/v1/insights/distribution", params: { buckets: 2 }

      expect(response).to have_http_status(:ok)
      expect(body["data"].first["bands"].size).to eq(2)
    end
  end
end
