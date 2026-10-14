# Generates realistic, deterministic employee data in bulk.
# Uses insert_all in batches (10,000 rows in a couple of seconds)
# instead of creating records one by one.
class EmployeeSeeder
  BATCH_SIZE = 1_000
  REFERENCE_DATE = Date.new(2026, 1, 1)

  COUNTRIES = {
    "India"   => { currency: "INR", range: 400_000..2_500_000 },
    "USA"     => { currency: "USD", range: 60_000..160_000 },
    "UK"      => { currency: "GBP", range: 35_000..100_000 },
    "Germany" => { currency: "EUR", range: 40_000..110_000 }
  }.freeze

  # department => [[job title, seniority multiplier], ...]
  DEPARTMENTS = {
    "Engineering" => [["Software Engineer", 1.0], ["Senior Software Engineer", 1.4],
                      ["Engineering Manager", 1.8], ["QA Engineer", 0.8]],
    "Sales"       => [["Sales Executive", 0.9], ["Account Manager", 1.1], ["Sales Manager", 1.6]],
    "HR"          => [["HR Executive", 0.8], ["HR Business Partner", 1.2], ["HR Manager", 1.5]],
    "Finance"     => [["Accountant", 0.9], ["Financial Analyst", 1.1], ["Finance Manager", 1.6]],
    "Marketing"   => [["Marketing Executive", 0.9], ["Content Strategist", 1.0], ["Marketing Manager", 1.5]],
    "Support"     => [["Support Agent", 0.7], ["Support Lead", 1.1], ["Support Manager", 1.4]]
  }.freeze

  FIRST_NAMES = %w[Aarav Asha Priya Rahul Neha Vikram Anjali Rohan Sneha Arjun Meera Karan Pooja
                   John Emma Liam Olivia Noah Sophia James Mia Lucas Hannah Oliver Charlotte
                   Felix Lena Jonas Clara Max Anna Paul Laura].freeze
  LAST_NAMES = %w[Sharma Verma Rao Patel Singh Kumar Gupta Nair Iyer Mehta Reddy Joshi
                  Smith Johnson Brown Taylor Wilson Clark Walker Hall Young King
                  Muller Schmidt Fischer Weber Becker Wagner].freeze

  def initialize(count: 10_000, seed: 42)
    @count = count
    @rng = Random.new(seed)
  end

  def call
    Employee.delete_all

    (0...@count).each_slice(BATCH_SIZE) do |indexes|
      Employee.insert_all(indexes.map { |i| build_row(i) })
    end

    @count
  end

  private

  def build_row(index)
    country, config = COUNTRIES.to_a.sample(random: @rng)
    department, titles = DEPARTMENTS.to_a.sample(random: @rng)
    title, multiplier = titles.sample(random: @rng)
    first = FIRST_NAMES.sample(random: @rng)
    last = LAST_NAMES.sample(random: @rng)
    now = Time.current

    {
      full_name: "#{first} #{last}",
      email: "#{first}.#{last}.#{index}@acme.com".downcase,
      job_title: title,
      department: department,
      country: country,
      currency: config[:currency],
      salary_cents: (@rng.rand(config[:range]) * multiplier).round * 100,
      hired_on: REFERENCE_DATE - @rng.rand(30..3_650),
      status: @rng.rand < 0.95 ? "active" : "terminated",
      created_at: now,
      updated_at: now
    }
  end
end
