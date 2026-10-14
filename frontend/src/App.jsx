import { Container, CssBaseline, Typography } from "@mui/material";
import EmployeesPage from "./pages/EmployeesPage";

export default function App() {
  return (
    <>
      <CssBaseline />
      <Container maxWidth="xl" sx={{ py: 3 }}>
        <Typography variant="h4" gutterBottom>ACME Salary Management</Typography>
        <EmployeesPage />
      </Container>
    </>
  );
}
