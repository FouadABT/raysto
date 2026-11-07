/** Cache formatter configuration only; no identity or business values are retained. */
const formatters = new Map<string, Intl.NumberFormat>();
export function numberFormatter(locale: string, options: Intl.NumberFormatOptions = {}) {
  const key = JSON.stringify([locale, options]);
  let formatter = formatters.get(key);
  if (!formatter) {
    formatter = new Intl.NumberFormat(locale, options);
    formatters.set(key, formatter);
    if (formatters.size > 24) formatters.delete(formatters.keys().next().value!);
  }
  return formatter;
}
