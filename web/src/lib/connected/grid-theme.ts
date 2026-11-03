import { themeQuartz } from "ag-grid-community";

/**
 * The console's one AG Grid theme, on the Material tokens of md-sys.css.
 * AG Grid writes each parameter into a CSS custom property, so `var(--…)`
 * values resolve against the page (checked on /ops/kit, 3 November).
 * Hover is the 8% state layer and selection the secondary container, as in
 * Material lists; corners are Material medium (12) and large (16).
 */
export const m3GridTheme = themeQuartz.withParams({
  accentColor: "var(--md-sys-color-primary)",
  backgroundColor: "var(--md-sys-color-surface-container-lowest)",
  foregroundColor: "var(--md-sys-color-on-surface)",
  textColor: "var(--md-sys-color-on-surface)",
  borderColor: "var(--raysto-sys-color-outline-soft)",
  chromeBackgroundColor: "var(--md-sys-color-surface)",
  headerBackgroundColor: "var(--md-sys-color-surface)",
  headerTextColor: "var(--md-sys-color-on-surface-variant)",
  headerFontWeight: 600,
  headerFontSize: 13,
  fontFamily: "var(--font-jakarta)",
  fontSize: 14,
  rowHeight: 52,
  headerHeight: 44,
  rowHoverColor: "color-mix(in srgb, var(--md-sys-color-on-surface) 8%, transparent)",
  selectedRowBackgroundColor: "color-mix(in srgb, var(--md-sys-color-secondary-container) 55%, transparent)",
  wrapperBorder: false,
  wrapperBorderRadius: 16,
  borderRadius: 12,
  columnBorder: false,
  cellHorizontalPadding: 18,
});
