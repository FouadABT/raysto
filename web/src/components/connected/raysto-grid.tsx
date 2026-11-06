"use client";
/**
 * The console's one grid: AG Grid Community on the Material theme, with a
 * quick search, a CSV export, a pinned totals row that follows the search
 * and the column filters, and plain words when there is nothing to show or
 * the rows are on their way. Columns come from grid-columns.ts.
 */
import { useCallback, useMemo, useRef, useState, type ReactNode } from "react";
import { useWorkspaceState } from "@/lib/connected/workspace-state";
import { AgGridReact } from "ag-grid-react";
import { AllCommunityModule, ModuleRegistry } from "ag-grid-community";
import type {
  CellClickedEvent,
  ColDef,
  GetRowIdParams,
  GridApi,
  GridState,
  ICellRendererParams,
  IRowNode,
  ProcessCellForExportParams,
  RowClickedEvent,
  RowSelectionOptions,
} from "ag-grid-community";
import { m3GridTheme } from "@/lib/connected/grid-theme";
import {
  columnIds,
  columnTotals,
  renderers,
  toneOf,
  totalsLabel,
  totalsLabelColumn,
  type ColumnContext,
} from "@/lib/connected/grid-columns";
import { Icon } from "./icons";
import "./raysto-grid.css";

// Registered here too, so a grid outside the workspace (a preview, a test page) still renders.
ModuleRegistry.registerModules([AllCommunityModule]);

const TOTALS = "__raystoTotals";
// A new key each time the totals change, so the grid redraws the pinned row
// instead of keeping cells whose underlying value did not change.
type TotalsRow = { [TOTALS]: Record<string, string>; key: number };

function Pill(p: ICellRendererParams) {
  if (p.value == null || p.value === "") return null;
  return (
    <span className={`ops-pill ${toneOf(p.value)}`}>
      {p.valueFormatted ?? String(p.value)}
    </span>
  );
}

function Bool(p: ICellRendererParams) {
  if (p.value == null || p.value === "") return null;
  const yes = p.value === true || p.value === "true";
  return (
    <span
      className={`ops-bool-mark ${yes ? "yes" : "no"}`}
      role="img"
      aria-label={p.valueFormatted ?? (yes ? "Yes" : "No")}
    >
      <Icon name={yes ? "check" : "cross"} size={18} />
    </span>
  );
}

function Id(p: ICellRendererParams) {
  const [copied, setCopied] = useState(false);
  if (p.value == null || p.value === "") return null;
  const text = String(p.value);
  return (
    <span className="ops-id-cell">
      <span className="ops-id-text">{p.valueFormatted ?? text}</span>
      <button
        type="button"
        className="ops-id-copy"
        aria-label={copied ? "Copied" : `Copy ${text}`}
        title={copied ? "Copied" : "Copy"}
        onClick={(e) => {
          e.stopPropagation();
          void navigator.clipboard?.writeText(text).then(
            () => {
              setCopied(true);
              setTimeout(() => setCopied(false), 1400);
            },
            () => undefined,
          );
        }}
      >
        <Icon name={copied ? "check" : "copy"} size={16} />
      </button>
    </span>
  );
}

/** The empty message reads the latest words when the grid shows it (a search can empty a full grid). */
function NoRows(p: { text: () => string }) {
  return <span className="ops-grid-overlay">{p.text()}</span>;
}

function TotalCell(p: ICellRendererParams & { text?: string }) {
  return p.text ? <span className="ops-total-cell">{p.text}</span> : null;
}

const components = {
  [renderers.pill]: Pill,
  [renderers.bool]: Bool,
  [renderers.id]: Id,
};
const base: ColDef = {
  sortable: true,
  filter: true,
  resizable: true,
  flex: 1,
  minWidth: 110,
};
const escape = (s: string) =>
  s.replace(/[&<>"']/g, (c) => `&#${c.charCodeAt(0)};`);

export function RaystoGrid<T>({
  label,
  rows,
  columns,
  loading = false,
  emptyText = "Nothing here yet.",
  getRowId,
  onRowClicked,
  onCellClicked,
  rowSelection,
  csvName,
  totals = true,
  search = true,
  tall = false,
  height,
  tools,
  tooltipShowDelay,
  className,
}: {
  /** The grid's accessible name, also the search box's ("Search orders"). */
  label: string;
  rows: T[] | undefined;
  columns: ColDef<T>[];
  loading?: boolean;
  /** Shown when there are no rows at all; a search with no match says so itself. */
  emptyText?: string;
  getRowId?: (p: GetRowIdParams<T>) => string;
  onRowClicked?: (e: RowClickedEvent<T>) => void;
  onCellClicked?: (e: CellClickedEvent<T>) => void;
  rowSelection?: RowSelectionOptions<T>;
  /** The CSV file's name without ".csv"; no name, no export button. */
  csvName?: string;
  /** A pinned totals row for columns that add up (money, counts). */
  totals?: boolean;
  search?: boolean;
  tall?: boolean;
  height?: number;
  /** Extra controls on the toolbar (chips, toggles). */
  tools?: ReactNode;
  tooltipShowDelay?: number;
  className?: string;
}) {
  const api = useRef<GridApi<T> | null>(null);
  const [query, setQuery] = useWorkspaceState(`grid:${label}:query`, "");
  const [gridMemory] = useWorkspaceState<{ current?: GridState }>(
    `grid:${label}:state`,
    {},
  );
  const initialGrid = useRef(gridMemory.current);
  const [shown, setShown] = useState<number>();
  const [sums, setSums] = useState<{
    text: Record<string, string>;
    key: number;
  }>({ text: {}, key: 0 });
  const ids = useMemo(() => columnIds(columns), [columns]);
  const labelAt = useMemo(() => totalsLabelColumn(columns), [columns]);
  const adds =
    totals &&
    columns.some((c) => (c.context as ColumnContext | undefined)?.total);

  // Pinned totals cells show their words; real rows keep their renderers.
  const columnDefs = useMemo<ColDef<T>[]>(
    () =>
      columns.map((c, i) => {
        const original = c.cellRenderer;
        const getter = c.valueGetter;
        const formatter = c.valueFormatter;
        return {
          ...c,
          colId: ids[i],
          ...(typeof getter === "function"
            ? { valueGetter: (p) => (p.node?.rowPinned ? null : getter(p)) }
            : {}),
          ...(typeof formatter === "function"
            ? { valueFormatter: (p) => (p.node?.rowPinned ? "" : formatter(p)) }
            : {}),
          cellRendererSelector: (p) => {
            if (p.node.rowPinned) {
              const row = p.data as TotalsRow | undefined;
              return {
                component: TotalCell,
                params: { text: row?.[TOTALS]?.[ids[i]] ?? "" },
              };
            }
            return original
              ? { component: original, params: c.cellRendererParams }
              : undefined;
          },
        } satisfies ColDef<T>;
      }),
    [columns, ids],
  );

  const recount = useCallback(() => {
    const grid = api.current;
    if (!grid || grid.isDestroyed()) return;
    const nodes: IRowNode<T>[] = [];
    grid.forEachNodeAfterFilter((n) => {
      if (n.data && !n.group) nodes.push(n);
    });
    setShown(nodes.length);
    if (!adds) return;
    const next = columnTotals(
      columns,
      nodes,
      (_c, id, node) => grid.getCellValue({ rowNode: node, colKey: id }),
      (node) => node.data as T,
    );
    if (labelAt >= 0) next[ids[labelAt]] = totalsLabel(nodes.length);
    setSums((old) =>
      JSON.stringify(old.text) === JSON.stringify(next)
        ? old
        : { text: next, key: old.key + 1 },
    );
  }, [adds, columns, ids, labelAt]);

  const pinned = useMemo(
    () =>
      adds && (rows?.length ?? 0) > 0
        ? [{ [TOTALS]: sums.text, key: sums.key } as unknown as T]
        : undefined,
    [adds, rows, sums],
  );

  const exportCsv = () => {
    api.current?.exportDataAsCsv({
      fileName: `${csvName ?? "raysto"}-${new Date().toISOString().slice(0, 10)}.csv`,
      skipPinnedBottom: true,
      processCellCallback: (p: ProcessCellForExportParams<T>) => {
        const ctx = p.column.getColDef().context as ColumnContext | undefined;
        if (ctx?.csv) return ctx.csv(p.value, p.node?.data);
        return p.formatValue(p.value);
      },
    });
  };

  const total = rows?.length ?? 0;
  const noRows = query && total > 0 ? `Nothing matches “${query}”.` : emptyText;
  const noRowsRef = useRef(noRows);
  noRowsRef.current = noRows;
  const noRowsParams = useMemo(() => ({ text: () => noRowsRef.current }), []);
  return (
    <div className={`ops-grid-block${className ? ` ${className}` : ""}`}>
      {(search || csvName || tools) && (
        <div className="ops-grid-tools">
          {search && (
            <label className="ops-grid-search">
              <Icon name="search" size={18} />
              <input
                type="search"
                value={query}
                placeholder="Search"
                aria-label={`Search ${label.toLowerCase()}`}
                onChange={(e) => setQuery(e.target.value)}
              />
            </label>
          )}
          {tools}
          <span className="ops-grid-count" aria-live="polite">
            {loading && rows === undefined
              ? "Loading…"
              : shown !== undefined && shown !== total
                ? `${shown} of ${total}`
                : `${total} ${total === 1 ? "row" : "rows"}`}
          </span>
          {csvName && (
            <button
              type="button"
              className="ops-grid-csv"
              onClick={exportCsv}
              disabled={total === 0}
            >
              <Icon name="download" size={18} /> CSV
            </button>
          )}
        </div>
      )}
      {query && total > 0 && shown === 0 && (
        <p className="ops-grid-nomatch" role="status">
          Nothing matches “{query}”.
        </p>
      )}
      <div
        className={`ops-grid${tall ? " tall" : ""}`}
        style={height ? { height } : undefined}
        role="region"
        aria-label={label}
      >
        <AgGridReact<T>
          theme={m3GridTheme}
          initialState={initialGrid.current}
          onStateUpdated={(event) => {
            gridMemory.current = event.state;
          }}
          rowData={rows ?? []}
          columnDefs={columnDefs}
          defaultColDef={base}
          components={components}
          loading={loading}
          overlayLoadingTemplate={`<span class="ops-grid-overlay" role="status">Loading ${escape(label.toLowerCase())}…</span>`}
          noRowsOverlayComponent={NoRows}
          noRowsOverlayComponentParams={noRowsParams}
          quickFilterText={query}
          pinnedBottomRowData={pinned}
          getRowId={
            getRowId &&
            ((p) => {
              const totalsRow = (p.data as unknown as TotalsRow | undefined)?.[
                TOTALS
              ]
                ? (p.data as unknown as TotalsRow)
                : undefined;
              return p.rowPinned || totalsRow
                ? `raysto-totals-${totalsRow?.key ?? 0}`
                : getRowId(p);
            })
          }
          onRowClicked={
            onRowClicked && ((e) => !e.node.rowPinned && onRowClicked(e))
          }
          onCellClicked={
            onCellClicked && ((e) => !e.node.rowPinned && onCellClicked(e))
          }
          rowSelection={rowSelection}
          tooltipShowDelay={tooltipShowDelay}
          onGridReady={(e) => {
            api.current = e.api;
            recount();
          }}
          onModelUpdated={recount}
          onGridPreDestroyed={() => {
            api.current = null;
          }}
        />
      </div>
    </div>
  );
}
