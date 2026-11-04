/**
 * The Accountant section's fixtures for the development preview (stream S1):
 * labelled sample books, never a real PayPal result. The preview refuses
 * every command, and the section must say so.
 */
import type { Json } from "./contracts";
import type { BillRow, Cashflow, PnlRow, RequestRow } from "./accountant";

export function accountantPreview(asOf: string): Record<string, (p: Json) => unknown> {
  const now = new Date(asOf).getTime();
  const at = (days: number) => new Date(now + days * 86400000).toISOString();
  const dayOf = (days: number) => at(days).slice(0, 10);
  const month = asOf.slice(0, 7);
  const bill = (b: Partial<BillRow> & Pick<BillRow, "id" | "vendor" | "category" | "amountMinor" | "state">): BillRow => ({
    account: "6100",
    vatMinor: 0,
    currency: "USD",
    payVia: "elsewhere",
    overdue: false,
    version: 1,
    createdAt: at(-3),
    issuedAt: at(-3),
    read: {},
    ...b,
  });
  const bills: BillRow[] = [
    bill({ id: 41, vendor: "Power Co", category: "electricity", reference: "INV-1001", amountMinor: 19610, vatMinor: 1610, state: "review", payVia: "paypal", payeeEmail: "billing@power.example", dueAt: at(12), recurring: "monthly", ageDays: 2, bucket: "0–30", read: { from: "ai", confidence: 0.94, explanation: "Power Co electricity for October, 196.10 USD due in 12 days; 8% above September." } }),
    bill({ id: 40, vendor: "City Water", category: "water", amountMinor: 4200, state: "approved", payVia: "paypal", payeeEmail: "pay@water.example", dueAt: at(-3), overdue: true, issuedAt: at(-40), ageDays: 40, bucket: "31–60" }),
    bill({ id: 39, vendor: "Rent Ltd", category: "rent", account: "6110", amountMinor: 180000, state: "paidElsewhere", proofMediaId: 77, paidAt: at(-2), read: { paidNote: "Bank transfer" } }),
    bill({ id: 38, vendor: "Fiber ISP", category: "internet", account: "6140", amountMinor: 4990, state: "paid", payVia: "paypal", payeeEmail: "billing@isp.example", providerBatchId: "SAMPLE-BATCH-1", payoutState: "completed", providerItemId: "SAMPLE-ITEM-1", paidAt: at(-5), recurring: "monthly" }),
    bill({ id: 42, vendor: "Fiber ISP", category: "internet", account: "6140", amountMinor: 4990, state: "expected", payVia: "paypal", payeeEmail: "billing@isp.example", dueAt: at(25), issuedAt: null, read: { basis: "Same as last month; the real bill replaces it when it arrives." } }),
  ];
  const requests: RequestRow[] = [
    { id: 7, kind: "link", payerName: "Acme Offices", payerEmail: "office@acme.example", description: "Team lunch for 12", amountMinor: 12000, currency: "USD", dueAt: at(-2), state: "sent", overdue: true, payUrl: "https://api.rays.to/pay/0123456789abcdef0123456789abcdef", remindersSent: 1, version: 2, createdAt: at(-9) },
    { id: 6, kind: "link", payerName: "Nadia's birthday", description: "Private room deposit", amountMinor: 5000, currency: "USD", state: "paid", overdue: false, providerOrderId: "SAMPLE-ORDER-6", providerCaptureId: "SAMPLE-CAPTURE-6", paidAt: at(-4), remindersSent: 0, version: 3, createdAt: at(-6) },
  ];
  const pnl: PnlRow[] = [
    { month, account: "4000", accountName: "Sales", group: "Revenue", amountMinor: 845000 },
    { month, account: "4200", accountName: "Catering and payment requests", group: "Revenue", amountMinor: 5000 },
    { month, account: "5000", accountName: "Cost of goods", group: "Costs", amountMinor: 262000 },
    { month, account: "6000", accountName: "PayPal fees", group: "Costs", amountMinor: 31400 },
    { month, account: "6100", accountName: "Utilities", group: "Costs", amountMinor: 21800 },
    { month, account: "6110", accountName: "Rent", group: "Costs", amountMinor: 180000 },
    { month, account: "6140", accountName: "Internet and phone", group: "Costs", amountMinor: 4990 },
  ];
  const history = Array.from({ length: 30 }, (_, i) => {
    const inMinor = 26000 + ((i * 3700) % 9000);
    const outMinor = i === 27 ? 180000 : 6000 + ((i * 1300) % 5000);
    return { date: dayOf(i - 29), inMinor, outMinor, netMinor: inMinor - outMinor };
  });
  let balance = 412000;
  const forecast = Array.from({ length: 30 }, (_, i) => {
    const items =
      i === 0
        ? [{ kind: "billDue", vendor: "City Water", amountMinor: 4200, overdue: true }]
        : i === 11
          ? [{ kind: "billToReview", vendor: "Power Co", amountMinor: 19610, overdue: false }]
          : i === 24
            ? [{ kind: "recurringExpected", vendor: "Fiber ISP", amountMinor: 4990, overdue: false }]
            : [];
    const outMinor = items.reduce((n, x) => n + x.amountMinor, 0);
    balance += 28000 - outMinor;
    return { date: dayOf(i + 1), inMinor: 28000, outMinor, balanceMinor: balance, items };
  });
  const cash: Cashflow = {
    currency: "USD",
    history,
    forecast,
    openingMinor: 412000,
    averageDailyInMinor: 28000,
    averageDailyNetMinor: 12000,
    lowestMinor: 435800,
    overdue: [],
    basis: "Money in is the last 30 days' average; money out is bills due and monthly bills expected. An estimate, not a promise.",
  };
  const sum = (test: (b: BillRow) => boolean) => bills.filter(test).reduce((n, b) => n + b.amountMinor, 0);
  return {
    bills: (p) => ({
      rows: bills,
      currency: "USD",
      summary: {
        dueMinor: sum((b) => ["review", "approved", "paying"].includes(b.state)),
        overdueMinor: sum((b) => b.overdue),
        overdueCount: bills.filter((b) => b.overdue).length,
        reviewCount: 1,
        expectedMinor: 4990,
        paidThisMonthMinor: 184990,
        aging: { "0–30": 19610, "31–60": 4200, "61–90": 0, "90+": 0 },
      },
      categories: ["electricity", "water", "rent", "internet"],
      ...(p.withFindings
        ? {
            findings: [
              { kind: "bill_overdue", ref: "bill:40", billId: 40, severity: "high", amountMinor: 4200, facts: "City Water 42.00 USD was due 3 day(s) ago.", fix: { command: "bill.pay", payload: { billId: 40 } } },
              { kind: "request_overdue", ref: "request:7", requestId: 7, severity: "medium", amountMinor: 12000, facts: "Acme Offices owes 120.00 USD for Team lunch for 12, due 2 day(s) ago; 1 reminder(s) sent.", fix: { command: "request.remind", payload: { requestId: 7 } } },
            ],
          }
        : {}),
    }),
    requests: () => ({ rows: requests, currency: "USD", summary: { outstandingMinor: 12000, overdueMinor: 12000, paidThisMonthMinor: 5000 } }),
    "ledger.pnl": () => ({ from: at(-92), to: asOf, currency: "USD", revenueMinor: 850000, costsMinor: 500190, netMinor: 349810, rows: pnl, feesEstimated: true }),
    "ledger.cashflow": () => cash,
    "ledger.vat": () => ({
      from: at(-92),
      to: asOf,
      currency: "USD",
      taxBps: 1000,
      taxConfigured: true,
      collectedMinor: 76800,
      paidMinor: 1610,
      dueMinor: 75190,
      rows: [{ month, collectedMinor: 76800, paidMinor: 1610, dueMinor: 75190 }],
    }),
  };
}
