// salary_cents (integer) -> "₹12,00,000" style string for the given currency
export function formatMoney(cents, currency) {
  return new Intl.NumberFormat("en-IN", {
    style: "currency",
    currency,
    maximumFractionDigits: 0,
  }).format(cents / 100);
}
