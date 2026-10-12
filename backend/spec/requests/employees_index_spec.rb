require "rails_helper"

RSpec.describe "GET /api/v1/employees", type: :request do
  before do
    create_list(:employee, 3, country: "India")
    create(:employee, country: "USA", currency: "USD", full_name: "John Smith")
  end

  let(:body) { JSON.parse(response.body) }

  it "returns employees with pagination meta" do
    get "/api/v1/employees", params: { page: 1, per_page: 2 }

    expect(response).to have_http_status(:ok)
    expect(body["data"].size).to eq(2)
    expect(body["meta"]).to include("page" => 1, "per_page" => 2, "total" => 4)
  end

  it "returns the next page" do
    get "/api/v1/employees", params: { page: 2, per_page: 3 }

    expect(body["data"].size).to eq(1)
  end

  it "filters by country" do
    get "/api/v1/employees", params: { country: "USA" }

    expect(body["data"].map { |e| e["full_name"] }).to eq(["John Smith"])
    expect(body["meta"]["total"]).to eq(1)
  end

  it "searches by name" do
    get "/api/v1/employees", params: { q: "john" }

    expect(body["data"].size).to eq(1)
  end

  it "caps per_page at 100" do
    get "/api/v1/employees", params: { per_page: 5000 }

    expect(body["meta"]["per_page"]).to eq(100)
  end
end
