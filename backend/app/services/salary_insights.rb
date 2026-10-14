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

  def by_department
    rows = Employee.with_status("active").pluck(:department, :currency, :salary_cents)

    rows.group_by { |dept, currency, _| [dept, currency] }.map do |(dept, currency), group|
      salaries = group.map(&:last)

      {
        department: dept,
        currency: currency,
        headcount: salaries.size,
        total_payroll: salaries.sum,
        avg: salaries.sum / salaries.size
      }
    end
  end

  def by_job_title(country: nil)
    rows = Employee.with_status("active").in_country(country)
                   .pluck(:job_title, :currency, :salary_cents)

    rows.group_by { |title, currency, _| [title, currency] }.map do |(title, currency), group|
      salaries = group.map(&:last)

      {
        job_title: title,
        currency: currency,
        headcount: salaries.size,
        min: salaries.min,
        avg: salaries.sum / salaries.size,
        max: salaries.max
      }
    end
  end

  def distribution(buckets: 5)
    rows = Employee.with_status("active").pluck(:currency, :salary_cents)

    rows.group_by(&:first).map do |currency, group|
      { currency: currency, bands: bands_for(group.map(&:last), buckets) }
    end
  end

  private

  def median(sorted)
    mid = sorted.size / 2
    sorted.size.odd? ? sorted[mid] : (sorted[mid - 1] + sorted[mid]) / 2
  end

  def bands_for(salaries, buckets)
    min = salaries.min
    width = [((salaries.max - min) / buckets.to_f).ceil, 1].max
    counts = Array.new(buckets, 0)

    salaries.each do |salary|
      index = [(salary - min) / width, buckets - 1].min
      counts[index] += 1
    end

    counts.each_with_index.map do |count, i|
      { from: min + i * width, to: min + (i + 1) * width, count: count }
    end
  end
end