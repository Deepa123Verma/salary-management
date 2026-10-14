# Seeds 10,000 employees (deterministic, safe to re-run).
count = EmployeeSeeder.new(count: 10_000).call
puts "Seeded #{count} employees"
