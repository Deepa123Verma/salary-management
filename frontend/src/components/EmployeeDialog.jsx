import { useEffect, useState } from "react";
import {
  Alert, Button, Dialog, DialogActions, DialogContent, DialogTitle,
  MenuItem, Stack, TextField,
} from "@mui/material";
import { api } from "../api";
import { COUNTRIES, CURRENCIES, DEPARTMENTS, STATUSES } from "../constants";

const EMPTY = {
  full_name: "", email: "", job_title: "", department: "Engineering",
  country: "India", currency: "INR", salary: "", hired_on: "", status: "active",
};

const toForm = (e) => ({ ...e, salary: String(e.salary_cents / 100) });

const toPayload = ({ salary, ...rest }) => ({
  ...rest,
  salary_cents: Math.round(Number(salary) * 100),
});

export default function EmployeeDialog({ open, employee, onClose, onSaved }) {
  const [form, setForm] = useState(EMPTY);
  const [errors, setErrors] = useState([]);
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    if (open) {
      setForm(employee ? toForm(employee) : EMPTY);
      setErrors([]);
    }
  }, [open, employee]);

  const change = (name) => (event) =>
    setForm((current) => ({ ...current, [name]: event.target.value }));

  const submit = async () => {
    setSaving(true);
    try {
      const payload = toPayload(form);
      if (employee) await api.updateEmployee(employee.id, payload);
      else await api.createEmployee(payload);
      onSaved();
    } catch (e) {
      setErrors(e.errors.length ? e.errors : [e.message]);
    } finally {
      setSaving(false);
    }
  };

  const select = (name, label, options) => (
    <TextField select label={label} value={form[name]} onChange={change(name)}>
      {options.map((o) => <MenuItem key={o} value={o}>{o}</MenuItem>)}
    </TextField>
  );

  return (
    <Dialog open={open} onClose={onClose} fullWidth maxWidth="sm">
      <DialogTitle>{employee ? "Edit employee" : "Add employee"}</DialogTitle>
      <DialogContent>
        <Stack spacing={2} sx={{ mt: 1 }}>
          {errors.length > 0 && (
            <Alert severity="error">
              {errors.map((message) => <div key={message}>{message}</div>)}
            </Alert>
          )}
          <TextField label="Full name" value={form.full_name} onChange={change("full_name")} />
          <TextField label="Email" value={form.email} onChange={change("email")} />
          <TextField label="Job title" value={form.job_title} onChange={change("job_title")} />
          {select("department", "Department", DEPARTMENTS)}
          {select("country", "Country", COUNTRIES)}
          {select("currency", "Currency", CURRENCIES)}
          <TextField label="Annual salary" type="number" value={form.salary}
                     onChange={change("salary")} />
          <TextField label="Hired on" type="date" value={form.hired_on}
                     onChange={change("hired_on")} InputLabelProps={{ shrink: true }} />
          {select("status", "Status", STATUSES)}
        </Stack>
      </DialogContent>
      <DialogActions>
        <Button onClick={onClose}>Cancel</Button>
        <Button variant="contained" onClick={submit} disabled={saving}>Save</Button>
      </DialogActions>
    </Dialog>
  );
}
