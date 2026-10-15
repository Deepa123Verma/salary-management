import { describe, expect, it } from "vitest";
import { formatMoney } from "./money";

describe("formatMoney", () => {
  it("converts cents to rupees with Indian digit grouping", () => {
    expect(formatMoney(120000000, "INR")).toContain("12,00,000");
  });

  it("uses the symbol of the given currency", () => {
    expect(formatMoney(12000000, "USD")).toContain("$");
  });

  it("shows no decimals", () => {
    expect(formatMoney(12345678, "USD")).not.toContain(".");
  });
});
