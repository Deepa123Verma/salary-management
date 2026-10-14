import { useCallback, useEffect, useState } from "react";
import {
  Alert, Box, Button, Chip, CircularProgress, MenuItem, Paper, Table, TableBody,
  TableCell, TableContainer, TableHead, TablePagination, TableRow, TextField,
} from "@mui/material";
import { api } from "../api";
import EmployeeDialog from "../components/EmployeeDialog";
import { COUNTRIES, DEPARTMENTS, STATUSES } from "../constants";
import { formatMoney } from "../money";
import { useDebounce } from "../hooks/useDebounce";

export default function EmployeesPage() {
  const [filters, setFilters] = useState({ q: "", country: "", department: "", status: "active" });
  const [page, setPage] = useState(0); // MUI pages start at 0, the API starts at 1
  const [perPage, setPerPage] = useState(25);
  const [result, setResult] = useState({ data: [], meta: { total: 0 } });
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [reloadKey, setReloadKey] = useState(0);
  const [dialog, setDialog] = useState({ open: false, employee: null });

  const debouncedQuery = useDebounce(filters.q);
  const reload = useCallback(() => setReloadKey((key) => key + 1), []);

  useEffect(() => {
    let ignore = false; // drop stale responses if the filters changed meanwhile
    setLoading(true);

    api
      .listEmployees({ ...filters, q: debouncedQuery, page: page + 1, per_page: perPage })
      .then((response) => { if (!ignore) { setResult(response); setError(null); } })
      .catch((e) => { if (!ignore) setError(e.message); })
      .finally(() => { if (!ignore) setLoading(false); });

    return () => { ignore = true; };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [debouncedQuery, filters.country, filters.department, filters.status, page, perPage, reloadKey]);

  const updateFilter = (name) => (event) => {
    setFilters((current) => ({ ...current, [name]: event.target.value }));
    setPage(0);
  };

  const handleSaved = () => {
    setDialog({ open: false, employee: null });
    reload();
  };

  const handleDelete = async (employee) => {
    if (!window.confirm(`Delete ${employee.full_name}?`)) return;
    try {
      await api.deleteEmployee(employee.id);
      reload();
    } catch (e) {
      setError(e.message);
    }
  };

  return (
    <Box>
      <Box sx={{ display: "flex", gap: 2, mb: 2, flexWrap: "wrap" }}>
        <TextField label="Search name, email or title" size="small" value={filters.q}
                   onChange={updateFilter("q")} sx={{ minWidth: 260 }} />
        <TextField select label="Country" size="small" value={filters.country}
                   onChange={updateFilter("country")} sx={{ minWidth: 140 }}>
          <MenuItem value="">All</MenuItem>
          {COUNTRIES.map((c) => <MenuItem key={c} value={c}>{c}</MenuItem>)}
        </TextField>
        <TextField select label="Department" size="small" value={filters.department}
                   onChange={updateFilter("department")} sx={{ minWidth: 160 }}>
          <MenuItem value="">All</MenuItem>
          {DEPARTMENTS.map((d) => <MenuItem key={d} value={d}>{d}</MenuItem>)}
        </TextField>
        <TextField select label="Status" size="small" value={filters.status}
                   onChange={updateFilter("status")} sx={{ minWidth: 140 }}>
          <MenuItem value="">All</MenuItem>
          {STATUSES.map((s) => <MenuItem key={s} value={s}>{s}</MenuItem>)}
        </TextField>
        {loading && <CircularProgress size={24} sx={{ alignSelf: "center" }} />}
        <Button variant="contained" sx={{ ml: "auto" }}
                onClick={() => setDialog({ open: true, employee: null })}>
          Add employee
        </Button>
      </Box>

      {error && <Alert severity="error" sx={{ mb: 2 }}>{error}</Alert>}

      <TableContainer component={Paper}>
        <Table size="small">
          <TableHead>
            <TableRow>
              <TableCell>Name</TableCell>
              <TableCell>Job title</TableCell>
              <TableCell>Department</TableCell>
              <TableCell>Country</TableCell>
              <TableCell align="right">Salary</TableCell>
              <TableCell>Status</TableCell>
              <TableCell align="right">Actions</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {result.data.map((e) => (
              <TableRow key={e.id} hover>
                <TableCell>{e.full_name}<br /><small>{e.email}</small></TableCell>
                <TableCell>{e.job_title}</TableCell>
                <TableCell>{e.department}</TableCell>
                <TableCell>{e.country}</TableCell>
                <TableCell align="right">{formatMoney(e.salary_cents, e.currency)}</TableCell>
                <TableCell>
                  <Chip size="small" label={e.status}
                        color={e.status === "active" ? "success" : "default"} />
                </TableCell>
                <TableCell align="right">
                  <Button size="small" onClick={() => setDialog({ open: true, employee: e })}>Edit</Button>
                  <Button size="small" color="error" onClick={() => handleDelete(e)}>Delete</Button>
                </TableCell>
              </TableRow>
            ))}
            {!loading && result.data.length === 0 && (
              <TableRow><TableCell colSpan={7} align="center">No employees found</TableCell></TableRow>
            )}
          </TableBody>
        </Table>
        <TablePagination
          component="div"
          count={result.meta.total}
          page={page}
          rowsPerPage={perPage}
          rowsPerPageOptions={[10, 25, 50, 100]}
          onPageChange={(_, newPage) => setPage(newPage)}
          onRowsPerPageChange={(e) => { setPerPage(Number(e.target.value)); setPage(0); }}
        />
      </TableContainer>

      <EmployeeDialog
        open={dialog.open}
        employee={dialog.employee}
        onClose={() => setDialog({ open: false, employee: null })}
        onSaved={handleSaved}
      />
    </Box>
  );
}
