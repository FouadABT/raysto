/**
 * Multi-page AG Studio starting layouts per section, on Studio's 24-column
 * canvas (rows of 16 px). Each page carries its own venue (and month)
 * filters, and charts cross-filter the page when a bar or slice is chosen.
 * A person's own changes are saved over these (studio.layout.save) and any
 * page added later still appears (mergeLayout in studio-canvas.tsx).
 *
 * Field ids are `sourceId.field`. Money fields hold major units of one
 * currency: the Group section hands Studio one currency at a time, so no
 * total ever adds two currencies together.
 */
import type { StudioState, StudioWidgetSpec } from "./studio-canvas";

type Place = { xTrack: number; yTrack: number; xSpan: number; ySpan: number };
type Page = { id: string; widgets: Record<string, StudioWidgetSpec>; widgetLayout: Record<string, Place> };

const at = (xTrack: number, yTrack: number, xSpan: number, ySpan: number): Place => ({ xTrack, yTrack, xSpan, ySpan });
const title = (text: string) => ({ title: { text, enabled: true } });

const listFilter = (text: string, field: string): StudioWidgetSpec => ({
  type: "list-filter",
  format: { ...title(text), style: { selection: { type: "multiple" } } },
  dataMapping: { value: [{ id: field }] },
});
const value = (text: string, field: string, aggregation = "sum"): StudioWidgetSpec => ({
  type: "value",
  format: title(text),
  dataMapping: { value: [{ id: field, aggregation }] },
});

/** The Group section's pages: Portfolio, Compare venues and Money. */
export function groupPages(_currency: string, money: boolean): StudioState {
  // Titles name no currency: a saved layout serves every currency the group
  // has, and the section says which one Studio is showing.
  const portfolio: Page = {
    id: "portfolio",
    widgets: {
      venue: listFilter("Venue", "venues.venue"),
      sales: value(`Paid sales`, "venues.sales"),
      orders: value("Paid orders", "venues.orders"),
      due: value(`Bills due within 7 days`, "venues.billsDueAmount"),
      bySales: {
        type: "column-chart-grouped",
        format: title(`Paid sales by venue`),
        dataMapping: { categoryKey: [{ id: "venues.venue" }], valueKey: [{ id: "venues.sales", aggregation: "sum" }] },
      },
      byOrders: {
        type: "donut-chart",
        format: title("Share of orders"),
        dataMapping: { categoryKey: [{ id: "venues.venue" }], valueKey: [{ id: "venues.orders", aggregation: "sum" }] },
      },
      table: {
        type: "grid",
        format: title("Every venue"),
        dataMapping: {
          cols: [
            { id: "venues.venue" },
            { id: "venues.sales" },
            { id: "venues.orders" },
            { id: "venues.averageTicket" },
            { id: "venues.refunds" },
            { id: "venues.billsDue" },
            { id: "venues.lowStock" },
            { id: "venues.liveDeliveries" },
          ],
        },
      },
    },
    widgetLayout: {
      venue: at(0, 0, 6, 8),
      sales: at(6, 0, 6, 8),
      orders: at(12, 0, 6, 8),
      due: at(18, 0, 6, 8),
      bySales: at(0, 8, 15, 18),
      byOrders: at(15, 8, 9, 18),
      table: at(0, 26, 24, 16),
    },
  };
  const compare: Page = {
    id: "compare",
    widgets: {
      venue: listFilter("Venue", "days.venue"),
      sales: value(`Paid sales`, "days.sales"),
      orders: value("Paid orders", "days.orders"),
      trend: {
        type: "combo-chart-grouped-column-line",
        format: title(`Sales by day and venue, with orders`),
        dataMapping: {
          categoryKey: [{ id: "days.day" }],
          valueKey: [{ id: "days.sales", aggregation: "sum" }],
          secondaryValueKey: [{ id: "days.orders", aggregation: "sum" }],
          legendKey: [{ id: "days.venue" }],
        },
      },
      pivot: {
        type: "pivot-grid",
        format: { ...title(`Paid sales, venue × day`), style: { grandTotalRow: { enabled: true }, totalColumns: true } },
        dataMapping: {
          rows: [{ id: "days.venue" }],
          columns: [{ id: "days.day" }],
          values: [{ id: "days.sales", aggregation: "sum" }],
        },
      },
    },
    widgetLayout: {
      venue: at(0, 0, 8, 8),
      sales: at(8, 0, 8, 8),
      orders: at(16, 0, 8, 8),
      trend: at(0, 8, 24, 18),
      pivot: at(0, 26, 24, 16),
    },
  };
  const books: Page = {
    id: "money",
    widgets: {
      venue: listFilter("Venue", "pnl.venue"),
      month: listFilter("Month", "pnl.month"),
      net: value(`Profit after costs`, "pnl.amount"),
      pnl: {
        type: "pivot-grid",
        format: {
          ...title(`Profit and loss by venue; costs are negative, the total row is profit`),
          style: { grandTotalRow: { enabled: true }, totalColumns: true },
        },
        dataMapping: {
          rows: [{ id: "pnl.kind" }, { id: "pnl.account" }],
          columns: [{ id: "pnl.venue" }],
          values: [{ id: "pnl.amount", aggregation: "sum" }],
        },
      },
      byMonth: {
        type: "column-chart-grouped",
        format: title(`Revenue and costs by month`),
        dataMapping: {
          categoryKey: [{ id: "pnl.month" }],
          valueKey: [{ id: "pnl.amount", aggregation: "sum" }],
          legendKey: [{ id: "pnl.kind" }],
        },
      },
    },
    widgetLayout: {
      venue: at(0, 0, 8, 8),
      month: at(8, 0, 8, 8),
      net: at(16, 0, 8, 8),
      pnl: at(0, 8, 24, 20),
      byMonth: at(0, 28, 24, 16),
    },
  };
  // An area manager reads sales and stock; the books are for owners and accountants.
  const pages = money ? [portfolio, compare, books] : [portfolio, compare];
  return { pages, selectedPageId: "portfolio" } as unknown as StudioState;
}

/** The pages by section, for the sections that open on Studio. */
export const studioPages = { group: groupPages } as const;
