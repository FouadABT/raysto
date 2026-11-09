/** Marketing-only fixtures. Never submitted to a business API. */
export const previewLabel = "Product preview · Illustrative data";
export const roles = [
  {
    name: "Owner",
    icon: "space_dashboard",
    title: "The bigger picture, without losing the detail.",
    description:
      "Connect service, AI-assisted cost investigations and PayPal payment outcomes in one view.",
    metric: "Service overview",
    value: "6 active orders",
    detail: "Tables, team and money, connected.",
  },
  {
    name: "Service",
    icon: "table_restaurant",
    title: "A little more attention at every table.",
    description:
      "See the floor, respond to requests and keep the next arrival in view.",
    metric: "Table 04",
    value: "Bill requested",
    detail: "4 guests · Terrace",
  },
  {
    name: "Kitchen",
    icon: "skillet",
    title: "A clear queue. A calmer kitchen.",
    description:
      "Follow new, preparing and ready tickets with the details the team needs.",
    metric: "Kitchen queue",
    value: "3 preparing",
    detail: "Order #24 · Croque monsieur",
  },
  {
    name: "Counter",
    icon: "point_of_sale",
    title: "Keep the next order moving.",
    description:
      "Review tickets and PayPal checkout status without losing the service context.",
    metric: "Counter ticket",
    value: "Order #24",
    detail: "Pickup · Ready for review",
  },
  {
    name: "Delivery",
    icon: "delivery_dining",
    title: "Make the handoff a clear next step.",
    description:
      "Keep the preparation, collection and delivery updates together.",
    metric: "Next handoff",
    value: "Ready to collect",
    detail: "Order #31 · Delivery",
  },
  {
    name: "Accounting",
    icon: "account_balance_wallet",
    title: "See the evidence behind the amount.",
    description:
      "Inspect AI-prepared bill proposals and PayPal payment, refund and payout evidence, with review before action.",
    metric: "Supplier bill",
    value: "€196.10",
    detail: "Needs review · Not posted",
  },
  {
    name: "Stock",
    icon: "inventory_2",
    title: "Know what is available for service.",
    description:
      "Connect dishes to ingredients, deliveries and the supplies behind them.",
    metric: "Supply review",
    value: "2 items to check",
    detail: "Availability stays visible.",
  },
] as const;

export const faqs = [
  [
    "Who is Raysto for?",
    "Raysto connects restaurant, café and quick-service operations in one workspace.",
  ],
  [
    "Can it support dine-in, pickup and delivery?",
    "Raysto brings dine-in, pickup and delivery workflows into the restaurant workspace. Available service modes depend on the restaurant's setup.",
  ],
  [
    "How does AI fit into the workflow?",
    "AI explains authorized records and prepares suggestions or proposals. Guests or authorized team members review the details before an order or financial change is confirmed. AI cannot approve a financial action itself.",
  ],
  [
    "Where does PayPal fit?",
    "PayPal supports customer checkout, refunds and supplier payouts where configured. Connected demos use PayPal Sandbox; these homepage product scenes are illustrative. Customer collection and supplier settlement remain separate, reviewed actions; AI does not approve or pay on its own.",
  ],
] as const;
