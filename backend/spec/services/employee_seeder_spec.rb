require "rails_helper"

RSpec.describe EmployeeSeeder do
  it "creates the requested number of employees" do
    expect { described_class.new(count: 200).call }.to change(Employee, :count).from(0).to(200)
  end

  it "is repeatable: running twice does not duplicate data" do
    2.times { described_class.new(count: 50).call }

    expect(Employee.count).to eq(50)
  end

  it "is deterministic for the same seed" do
    described_class.new(count: 20, seed: 1).call
    first_run = Employee.order(:id).pluck(:full_name, :salary_cents)

    described_class.new(count: 20, seed: 1).call
    second_run = Employee.order(:id).pluck(:full_name, :salary_cents)

    expect(second_run).to eq(first_run)
  end

  it "creates only valid employees" do
    described_class.new(count: 100).call

    expect(Employee.all.reject(&:valid?)).to be_empty
  end

  it "spreads employees across several countries and currencies" do
    described_class.new(count: 200).call

    expect(Employee.distinct.pluck(:country).size).to be > 1
    expect(Employee.distinct.pluck(:currency).size).to be > 1
  end

  it "keeps each country on its own currency" do
    described_class.new(count: 200).call

    pairs = Employee.distinct.pluck(:country, :currency)
    expect(pairs.map(&:first).uniq.size).to eq(pairs.size)
  end
end
