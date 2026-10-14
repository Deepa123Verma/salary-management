const BASE = import.meta.env.VITE_API_URL ?? "http://localhost:3000";

async function request(path, options = {}) {
  const response = await fetch(`${BASE}${path}`, {
    headers: { "Content-Type": "application/json" },
    ...options,
  });

  if (response.status === 204) return null;

  const body = await response.json();
  if (!response.ok) {
    const error = new Error(body.error || "Request failed");
    error.errors = body.errors || [];
    throw error;
  }
  return body;
}

const toQuery = (params) => {
  const clean = Object.fromEntries(
    Object.entries(params).filter(([, v]) => v !== "" && v != null)
  );
  return new URLSearchParams(clean).toString();
};

export const api = {
  listEmployees: (params) => request(`/api/v1/employees?${toQuery(params)}`),
  createEmployee: (employee) =>
    request("/api/v1/employees", { method: "POST", body: JSON.stringify({ employee }) }),
  updateEmployee: (id, employee) =>
    request(`/api/v1/employees/${id}`, { method: "PATCH", body: JSON.stringify({ employee }) }),
  deleteEmployee: (id) => request(`/api/v1/employees/${id}`, { method: "DELETE" }),
  byCountry: () => request("/api/v1/insights/by_country"),
  byDepartment: () => request("/api/v1/insights/by_department"),
  byJobTitle: (country) => request(`/api/v1/insights/by_job_title?${toQuery({ country })}`),
  distribution: (buckets = 5) => request(`/api/v1/insights/distribution?buckets=${buckets}`),
};
