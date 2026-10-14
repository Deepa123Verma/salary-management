import { useState } from "react";
import { Box, Container, CssBaseline, Tab, Tabs, Typography } from "@mui/material";
import EmployeesPage from "./pages/EmployeesPage";
import InsightsPage from "./pages/InsightsPage";

export default function App() {
  const [tab, setTab] = useState("insights");

  return (
    <>
      <CssBaseline />
      <Container maxWidth="xl" sx={{ py: 3 }}>
        <Typography variant="h4" gutterBottom>ACME Salary Management</Typography>
        <Tabs value={tab} onChange={(_, value) => setTab(value)} sx={{ mb: 3 }}>
          <Tab value="insights" label="Insights" />
          <Tab value="employees" label="Employees" />
        </Tabs>
        <Box>{tab === "insights" ? <InsightsPage /> : <EmployeesPage />}</Box>
      </Container>
    </>
  );
}
