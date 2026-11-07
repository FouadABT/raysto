/** Short-lived presentation snapshots. Never used to authorize a command. */
export class ReadSnapshots {
  private entries = new Map<string, { value: unknown; at: number }>();
  epoch = 0;
  private listeners = new Set<(ended: boolean) => void>();
  constructor(private now = () => Date.now()) {}
  get<T>(key: string): T | undefined {
    const item = this.entries.get(key);
    if (!item) return;
    if (this.now() - item.at >= 120_000) {
      this.entries.delete(key);
      return;
    }
    return item.value as T;
  }
  put<T>(key: string, value: T) {
    this.entries.delete(key);
    this.entries.set(key, { value, at: this.now() });
    while (this.entries.size > 12) this.entries.delete(this.entries.keys().next().value!);
  }
  clear(ended = false) { this.epoch++; this.entries.clear(); for (const listener of this.listeners) listener(ended); }
  subscribe(listener: (ended: boolean) => void) { this.listeners.add(listener); return () => { this.listeners.delete(listener); }; }
}
const scopes = new WeakMap<object, ReadSnapshots>();
export function overviewSnapshots(identity: object) {
  let store = scopes.get(identity);
  if (!store) { store = new ReadSnapshots(); scopes.set(identity, store); }
  return store;
}
export function clearOverviewSnapshots(identity: object, ended = false) { scopes.get(identity)?.clear(ended); }
