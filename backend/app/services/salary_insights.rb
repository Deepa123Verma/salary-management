class SalaryInsights
  def by_country
    rows = Employee.with_status("active").pluck(:country, :currency, :salary_cents)

    rows.group_by { |country, currency, _| [country, currency] }.map do |(country, currency), group|
      salaries = group.map(&:last).sort

      {
        country: country,
        currency: currency,
        headcount: salaries.size,
        min: salaries.first,
        avg: salaries.sum / salaries.size,
        median: median(salaries),
        max: salaries.last
      }
    end
  end

  private

  def median(sorted)
    mid = sorted.size / 2
    sorted.size.odd? ? sorted[mid] : (sorted[mid - 1] + sorted[mid]) / 2
  end
end