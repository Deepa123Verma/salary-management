import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { beforeEach, describe, expect, it, vi } from "vitest";
import { api } from "../api";
import EmployeeDialog from "./EmployeeDialog";

vi.mock("../api", () => ({
  api: { createEmployee: vi.fn(), updateEmployee: vi.fn() },
}));

const renderDialog = (props = {}) =>
  render(<EmployeeDialog open employee={null} onClose={() => {}} onSaved={() => {}} {...props} />);

describe("EmployeeDialog", () => {
  beforeEach(() => vi.clearAllMocks());

  it("shows the validation errors returned by the API", async () => {
    api.createEmployee.mockRejectedValue(
      Object.assign(new Error("Unprocessable"), { errors: ["Email is invalid"] })
    );
    renderDialog();

    await userEvent.click(screen.getByRole("button", { name: "Save" }));

    expect(await screen.findByText("Email is invalid")).toBeInTheDocument();
  });

  it("sends the salary to the API in cents", async () => {
    api.createEmployee.mockResolvedValue({});
    const onSaved = vi.fn();
    renderDialog({ onSaved });

    await userEvent.type(screen.getByLabelText("Annual salary"), "1500");
    await userEvent.click(screen.getByRole("button", { name: "Save" }));

    expect(api.createEmployee).toHaveBeenCalledWith(
      expect.objectContaining({ salary_cents: 150000 })
    );
    expect(onSaved).toHaveBeenCalled();
  });
});
