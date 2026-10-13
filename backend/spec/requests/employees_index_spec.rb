require "rails_helper"

RSpec.describe "Employees API", type: :request do
  let(:body) { JSON.parse(response.body) }
  let(:valid_attrs) do
    { full_name: "Asha Rao", email: "asha@acme.com", job_title: "Engineer",
      department: "Engineering", country: "India", currency: "INR",
      salary_cents: 150_000_000, hired_on: "2024-03-01", status: "active" }
  end

  describe "GET /api/v1/employees" do
    before do
      create_list(:employee, 3, country: "India")
      create(:employee, country: "USA", currency: "USD", full_name: "John Smith")
    end

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

  describe "GET /api/v1/employees/:id" do
    it "returns the employee" do
      employee = create(:employee)
      get "/api/v1/employees/#{employee.id}"

      expect(response).to have_http_status(:ok)
      expect(body["id"]).to eq(employee.id)
    end

    it "returns 404 when not found" do
      get "/api/v1/employees/0"

      expect(response).to have_http_status(:not_found)
      expect(body["error"]).to be_present
    end
  end

  describe "POST /api/v1/employees" do
    it "creates an employee" do
      expect {
        post "/api/v1/employees", params: { employee: valid_attrs }, as: :json
      }.to change(Employee, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(body["email"]).to eq("asha@acme.com")
    end

    it "returns 422 with error messages when invalid" do
      post "/api/v1/employees", params: { employee: valid_attrs.merge(salary_cents: -5) }, as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(body["errors"]).not_to be_empty
    end
  end

  describe "PATCH /api/v1/employees/:id" do
    it "updates the employee" do
      employee = create(:employee)
      patch "/api/v1/employees/#{employee.id}",
            params: { employee: { job_title: "Staff Engineer" } }, as: :json

      expect(response).to have_http_status(:ok)
      expect(employee.reload.job_title).to eq("Staff Engineer")
    end

    it "returns 422 for invalid data" do
      employee = create(:employee)
      patch "/api/v1/employees/#{employee.id}",
            params: { employee: { email: "bad" } }, as: :json

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "DELETE /api/v1/employees/:id" do
    it "deletes the employee" do
      employee = create(:employee)

      expect {
        delete "/api/v1/employees/#{employee.id}"
      }.to change(Employee, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end
  end
end