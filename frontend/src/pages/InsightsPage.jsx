import { useEffect, useMemo, useState } from "react";
import {
  Alert, Box, Card, CardContent, CircularProgress, MenuItem, Paper, Table, TableBody,
  TableCell, TableContainer, TableHead, TableRow, TextField, Typography,
} from "@mui/material";
import { Bar, BarChart, CartesianGrid, ResponsiveContainer, Tooltip, XAxis, YAxis } from "recharts";
import { api } from "../api";
import { COUNTRIES } from "../constants";
import { formatMoney } from "../money";

function Section({ title, subtitle, children }) {
  return (
    <Box sx={{ mb: 4 }}>
      <Typography variant="h6">{title}</Typography>
      {subtitle && <Typography variant="body2" color="text.secondary" sx={{ mb: 1 }}>{subtitle}</Typography>}
      {children}
    </Box>
  );
}

function StatCard({ label, value }) {
  return (
    <Card sx={{ minWidth: 180 }}>
      <CardContent>
        <Typography variant="body2" color="text.secondary">{label}</Typography>
        <Typography variant="h5">{value}</Typography>
      </CardContent>
    </Card>
  );
}

export default function InsightsPage() {
  const [data, setData] = useState(null);
  const [error, setError] = useState(null);
  const [currency, setCurrency] = useState("INR");
  const [jobCountry, setJobCountry] = useState("India");
  const [jobTitles, setJobTitles] = useState([]);

  useEffect(() => {
    Promise.all([api.byCountry(), api.byDepartment(), api.distribution(6)])
      .then(([country, department, distribution]) =>
        setData({ country: country.data, department: department.data, distribution: distribution.data }))
      .catch((e) => setError(e.message));
  }, []);

  useEffect(() => {
    api.byJobTitle(jobCountry).then((r) => setJobTitles(r.data)).catch((e) => setError(e.message));
  }, [jobCountry]);

  // Headcount does not depend on currency, so departments can be summed across currencies.
  const departmentHeadcount = useMemo(() => {
    if (!data) return [];
    const totals = {};
    data.department.forEach((row) => {
      totals[row.department] = (totals[row.department] || 0) + row.headcount;
    });
    return Object.entries(totals).map(([department, headcount]) => ({ department, headcount }));
  }, [data]);

  const bands = useMemo(() => {
    const entry = data?.distribution.find((d) => d.currency === currency);
    return (entry?.bands ?? []).map((b) => ({
      label: `${formatMoney(b.from, currency)} – ${formatMoney(b.to, currency)}`,
      count: b.count,
    }));
  }, [data, currency]);

  if (error) return <Alert severity="error">{error}</Alert>;
  if (!data) return <CircularProgress />;

  const totalHeadcount = data.country.reduce((sum, row) => sum + row.headcount, 0);

  return (
    <Box>
      <Box sx={{ display: "flex", gap: 2, mb: 4, flexWrap: "wrap" }}>
        <StatCard label="Active employees" value={totalHeadcount.toLocaleString()} />
        <StatCard label="Countries" value={data.country.length} />
        <StatCard label="Departments" value={departmentHeadcount.length} />
      </Box>

      <Section title="Salary by country"
               subtitle="Each country is shown in its own currency. Currencies are never added together.">
        <TableContainer component={Paper}>
          <Table size="small">
            <TableHead>
              <TableRow>
                <TableCell>Country</TableCell>
                <TableCell align="right">Headcount</TableCell>
                <TableCell align="right">Min</TableCell>
                <TableCell align="right">Average</TableCell>
                <TableCell align="right">Median</TableCell>
                <TableCell align="right">Max</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {data.country.map((r) => (
                <TableRow key={r.country}>
                  <TableCell>{r.country} ({r.currency})</TableCell>
                  <TableCell align="right">{r.headcount.toLocaleString()}</TableCell>
                  <TableCell align="right">{formatMoney(r.min, r.currency)}</TableCell>
                  <TableCell align="right">{formatMoney(r.avg, r.currency)}</TableCell>
                  <TableCell align="right">{formatMoney(r.median, r.currency)}</TableCell>
                  <TableCell align="right">{formatMoney(r.max, r.currency)}</TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </TableContainer>
      </Section>

      <Section title="Headcount by department">
        <Paper sx={{ p: 2, height: 300 }}>
          <ResponsiveContainer width="100%" height="100%">
            <BarChart data={departmentHeadcount}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="department" />
              <YAxis />
              <Tooltip />
              <Bar dataKey="headcount" fill="#1976d2" />
            </BarChart>
          </ResponsiveContainer>
        </Paper>
      </Section>

      <Section title="Payroll by department" subtitle="Total annual payroll, per currency.">
        <TableContainer component={Paper}>
          <Table size="small">
            <TableHead>
              <TableRow>
                <TableCell>Department</TableCell>
                <TableCell>Currency</TableCell>
                <TableCell align="right">Headcount</TableCell>
                <TableCell align="right">Average salary</TableCell>
                <TableCell align="right">Total payroll</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {data.department.map((r) => (
                <TableRow key={`${r.department}-${r.currency}`}>
                  <TableCell>{r.department}</TableCell>
                  <TableCell>{r.currency}</TableCell>
                  <TableCell align="right">{r.headcount.toLocaleString()}</TableCell>
                  <TableCell align="right">{formatMoney(r.avg, r.currency)}</TableCell>
                  <TableCell align="right">{formatMoney(r.total_payroll, r.currency)}</TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </TableContainer>
      </Section>

      <Section title="Salary distribution" subtitle="How many employees fall into each salary band.">
        <TextField select size="small" label="Currency" value={currency}
                   onChange={(e) => setCurrency(e.target.value)} sx={{ mb: 1, minWidth: 140 }}>
          {data.distribution.map((d) => <MenuItem key={d.currency} value={d.currency}>{d.currency}</MenuItem>)}
        </TextField>
        <Paper sx={{ p: 2, height: 340 }}>
          <ResponsiveContainer width="100%" height="100%">
            <BarChart data={bands}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="label" tick={{ fontSize: 11 }} />
              <YAxis />
              <Tooltip />
              <Bar dataKey="count" fill="#2e7d32" />
            </BarChart>
          </ResponsiveContainer>
        </Paper>
      </Section>

      <Section title="Pay by job title">
        <TextField select size="small" label="Country" value={jobCountry}
                   onChange={(e) => setJobCountry(e.target.value)} sx={{ mb: 1, minWidth: 140 }}>
          {COUNTRIES.map((c) => <MenuItem key={c} value={c}>{c}</MenuItem>)}
        </TextField>
        <TableContainer component={Paper}>
          <Table size="small">
            <TableHead>
              <TableRow>
                <TableCell>Job title</TableCell>
                <TableCell align="right">Headcount</TableCell>
                <TableCell align="right">Min</TableCell>
                <TableCell align="right">Average</TableCell>
                <TableCell align="right">Max</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {jobTitles.map((r) => (
                <TableRow key={`${r.job_title}-${r.currency}`}>
                  <TableCell>{r.job_title}</TableCell>
                  <TableCell align="right">{r.headcount.toLocaleString()}</TableCell>
                  <TableCell align="right">{formatMoney(r.min, r.currency)}</TableCell>
                  <TableCell align="right">{formatMoney(r.avg, r.currency)}</TableCell>
                  <TableCell align="right">{formatMoney(r.max, r.currency)}</TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </TableContainer>
      </Section>
    </Box>
  );
}
