"use client";
import {
  createContext,
  useContext,
  useEffect,
  useRef,
  useState,
  type ReactNode,
} from "react";
import {
  advanceOrder,
  calculate,
  can,
  seedState,
  validateCheckout,
  type CartLine,
  type DemoState,
  type Order,
  type Product,
  type Role,
  type Reservation,
  type Staff,
} from "./domain";

const STORAGE = "raysto.web.demo.v1";
type Recipe = (draft: DemoState) => void;
interface Store {
  state: DemoState;
  ready: boolean;
  storageError: string;
  toast: string;
  notify: (message: string) => void;
  update: (recipe: Recipe, section?: string) => boolean;
  login: (role: Role) => void;
  logout: () => void;
  reset: () => void;
  addItem: (
    product: Product,
    quantity: number,
    option: string,
    note: string,
  ) => void;
  checkout: (input: {
    address: string;
    tip: number;
    coupon: boolean;
    paid: boolean;
  }) => string | null;
  progress: (id: string) => void;
  cancelOrder: (id: string, guest?: boolean) => void;
  payOrder: (id: string) => void;
  refundOrder: (id: string) => void;
  joinTable: (table: number, guests: number) => boolean;
  closeTable: (table: number) => void;
  requestService: (kind: string) => void;
  saveProduct: (product: Product) => boolean;
  reserve: (reservation: Omit<Reservation, "id" | "status">) => boolean;
  saveStaff: (staff: Staff) => boolean;
}
const Context = createContext<Store | null>(null);
const uid = (prefix: string) => `${prefix}-${crypto.randomUUID().slice(0, 8)}`;
function validState(value: unknown): value is DemoState {
  if (!value || typeof value !== "object") return false;
  const s = value as DemoState;
  return (
    s.version === 1 &&
    [
      "products",
      "orders",
      "tables",
      "cart",
      "reservations",
      "requests",
      "staff",
      "favorites",
      "activity",
      "waitlist",
      "reviews",
    ].every((key) => Array.isArray(s[key as keyof DemoState])) &&
    !!s.settings &&
    typeof s.settings.restaurant === "string" &&
    !!s.profile &&
    typeof s.profile.name === "string" &&
    typeof s.profile.email === "string" &&
    typeof s.profile.address === "string" &&
    (s.role === null ||
      ["owner", "manager", "waiter", "kitchen", "courier"].includes(s.role)) &&
    ["Dine-in", "Pickup", "Delivery"].includes(s.channel) &&
    s.products.every(
      (p) => typeof p.id === "string" && Number.isInteger(p.price),
    ) &&
    s.orders.every(
      (o) =>
        Array.isArray(o.lines) &&
        Array.isArray(o.events) &&
        Number.isInteger(o.total),
    ) &&
    s.cart.every(
      (l) =>
        typeof l.id === "string" &&
        Number.isInteger(l.quantity) &&
        l.quantity > 0 &&
        Number.isInteger(l.price),
    )
  );
}
export function DemoProvider({ children }: { children: ReactNode }) {
  const [state, setState] = useState<DemoState>(seedState);
  const current = useRef(state);
  const [ready, setReady] = useState(false);
  const [toast, notify] = useState("");
  const [storageError, setStorageError] = useState("");
  useEffect(() => {
    try {
      const raw = localStorage.getItem(STORAGE);
      if (raw) {
        const parsed = JSON.parse(raw);
        if (!validState(parsed)) throw new Error("Invalid demo data");
        current.current = parsed;
        setState(parsed);
      }
    } catch {
      setStorageError(
        "Saved demo data could not be loaded. You can reset the demo in preferences.",
      );
    }
    setReady(true);
    const sync = (event: StorageEvent) => {
      if (event.key !== STORAGE || !event.newValue) return;
      try {
        const parsed = JSON.parse(event.newValue);
        if (validState(parsed)) {
          current.current = parsed;
          setState(parsed);
        }
      } catch {
        /* Preserve current state on malformed external storage. */
      }
    };
    window.addEventListener("storage", sync);
    return () => window.removeEventListener("storage", sync);
  }, []);
  useEffect(() => {
    document.documentElement.dataset.theme = state.settings.dark
      ? "dark"
      : "light";
    document.documentElement.dataset.motion = state.settings.reducedMotion
      ? "reduced"
      : "normal";
  }, [state.settings.dark, state.settings.reducedMotion]);
  useEffect(() => {
    if (!toast) return;
    const timer = setTimeout(() => notify(""), 5000);
    return () => clearTimeout(timer);
  }, [toast]);
  function update(recipe: Recipe, section?: string) {
    try {
      if (section && !can(current.current.role, section))
        throw new Error("This demo role does not have access to that action.");
      const next = structuredClone(current.current);
      recipe(next);
      current.current = next;
      setState(next);
      try {
        localStorage.setItem(STORAGE, JSON.stringify(next));
        setStorageError("");
      } catch {
        setStorageError(
          "Browser storage is unavailable. Changes will last only for this open session.",
        );
      }
      return true;
    } catch (error) {
      notify(
        error instanceof Error
          ? error.message
          : "That action could not be completed.",
      );
      return false;
    }
  }
  function event(s: DemoState, text: string) {
    s.activity.unshift({ id: uid("a"), text, time: new Date().toISOString() });
    s.activity = s.activity.slice(0, 100);
  }
  function login(role: Role) {
    update((s) => {
      if (!s.staff.some((person) => person.role === role && person.active))
        throw new Error("This demo role has no active team member.");
      s.role = role;
    });
  }
  function addItem(
    product: Product,
    quantity: number,
    option: string,
    note: string,
  ) {
    if (
      update((s) => {
        const p = s.products.find((item) => item.id === product.id);
        if (!p?.available)
          throw new Error("This item is currently unavailable.");
        if (!Number.isInteger(quantity) || quantity < 1 || quantity > 20)
          throw new Error("Choose between 1 and 20 portions.");
        const line: CartLine = {
          id: uid("line"),
          productId: p.id,
          name: p.name,
          price: p.price + (option === "Large" ? 2500 : 0),
          quantity,
          option,
          note: note.trim().slice(0, 300),
          image: p.image,
        };
        s.cart.push(line);
      })
    )
      notify("Added to your basket.");
  }
  function checkout(input: {
    address: string;
    tip: number;
    coupon: boolean;
    paid: boolean;
  }) {
    let id: string | null = null;
    update((s) => {
      validateCheckout(s, input.address);
      if (!Number.isInteger(input.tip) || input.tip < 0 || input.tip > 100000)
        throw new Error("Choose a valid tip.");
      id = uid("RS");
      const now = new Date().toISOString();
      const order: Order = {
        id,
        guest: s.profile.name || "Guest",
        channel: s.channel,
        table: s.channel === "Dine-in" ? s.visit?.table : undefined,
        visitId: s.channel === "Dine-in" ? s.visit?.id : undefined,
        lines: structuredClone(s.cart),
        ...calculate(
          s.cart,
          s.channel,
          s.settings.deliveryFee,
          input.tip,
          input.coupon,
        ),
        status: "New",
        payment: input.paid ? "Paid" : "Unpaid",
        createdAt: now,
        address: input.address,
        customer: true,
        events: [{ label: "Demo order placed", time: now }],
      };
      s.orders.unshift(order);
      s.cart = [];
      event(s, `${id} placed · ${order.channel}`);
    });
    return id;
  }
  function progress(id: string) {
    if (
      update(
        (s) => {
          const order = s.orders.find((o) => o.id === id);
          if (!order || !s.role) throw new Error("Order not found.");
          order.status = advanceOrder(order, s.role);
          order.events.push({
            label: order.status,
            time: new Date().toISOString(),
          });
          event(s, `${id} · ${order.status}`);
        },
        current.current.role === "courier"
          ? "deliveries"
          : current.current.role === "kitchen"
            ? "kitchen"
            : "orders",
      )
    )
      notify("Order updated.");
  }
  function cancelOrder(id: string, guest = false) {
    if (
      update((s) => {
        const order = s.orders.find((o) => o.id === id);
        if (!order) throw new Error("Order not found.");
        if (guest && !order.customer)
          throw new Error("This is not your demo order.");
        if (!guest && !["owner", "manager"].includes(s.role || ""))
          throw new Error("Only management can cancel restaurant orders.");
        if (!["New", "Accepted"].includes(order.status))
          throw new Error(
            "Preparation has started; this order can no longer be cancelled.",
          );
        order.status = "Cancelled";
        if (order.payment === "Paid") order.payment = "Refunded";
        order.events.push({
          label: "Cancelled",
          time: new Date().toISOString(),
        });
        event(s, `${id} cancelled`);
      })
    )
      notify("Demo order cancelled. Any demo payment was refunded.");
  }
  function payOrder(id: string) {
    if (
      update((s) => {
        const order = s.orders.find((o) => o.id === id);
        if (
          !order ||
          order.status === "Cancelled" ||
          order.payment !== "Unpaid"
        )
          throw new Error("This order has no payable balance.");
        if (
          !order.customer &&
          !["owner", "manager", "waiter"].includes(s.role || "")
        )
          throw new Error("This role cannot collect payment.");
        order.payment = "Paid";
        event(s, `${id} · demo payment recorded`);
      })
    )
      notify("Demo payment recorded. No money was charged.");
  }
  function refundOrder(id: string) {
    if (
      update((s) => {
        if (!["owner", "manager"].includes(s.role || ""))
          throw new Error("Only management can issue a demo refund.");
        const order = s.orders.find((o) => o.id === id);
        if (!order || order.payment !== "Paid")
          throw new Error("Only paid orders can be refunded.");
        order.payment = "Refunded";
        event(s, `${id} · demo refund recorded`);
      }, "payments")
    )
      notify("Demo refund recorded.");
  }
  function joinTable(table: number, guests: number) {
    const ok = update((s) => {
      if (
        s.visit &&
        s.tables.some(
          (t) => t.visitId === s.visit!.id && t.status === "Occupied",
        )
      )
        throw new Error("You already have an active table visit.");
      const found = s.tables.find((t) => t.id === table);
      if (!found || found.status !== "Available")
        throw new Error(
          "This table is unavailable. Please ask your host for help.",
        );
      if (guests < 1 || guests > found.seats)
        throw new Error(`Choose up to ${found.seats} guests.`);
      const id = uid("visit");
      found.status = "Occupied";
      found.visitId = id;
      found.guests = guests;
      s.visit = { id, table, guests };
      s.channel = "Dine-in";
      event(s, `Table ${table} · ${guests} guests seated`);
    });
    return ok;
  }
  function closeTable(table: number) {
    if (
      update((s) => {
        const t = s.tables.find((item) => item.id === table);
        if (!t || t.status !== "Occupied")
          throw new Error("There is no active visit here.");
        const orders = s.orders.filter((o) => o.visitId === t.visitId);
        if (
          orders.some(
            (o) =>
              o.status !== "Cancelled" &&
              (o.payment === "Unpaid" ||
                !["Completed", "Cancelled"].includes(o.status)),
          )
        )
          throw new Error(
            "Complete the orders and settle the bill before closing this visit.",
          );
        if (s.visit?.id === t.visitId) {
          s.visit = null;
          s.channel = "Pickup";
        }
        t.status = "Needs reset";
        t.guests = 0;
        t.visitId = undefined;
        event(s, `Table ${table} · visit closed`);
      }, "tables")
    )
      notify("Visit closed. The table needs resetting.");
  }
  function requestService(kind: string) {
    if (
      update((s) => {
        if (
          !s.visit ||
          !s.tables.some(
            (t) => t.visitId === s.visit!.id && t.status === "Occupied",
          )
        )
          throw new Error("Join a table first.");
        if (
          s.requests.some(
            (r) =>
              r.table === s.visit!.table &&
              r.kind === kind &&
              r.status !== "Completed",
          )
        )
          throw new Error("Your request is already with the team.");
        s.requests.unshift({
          id: uid("R"),
          table: s.visit.table,
          kind,
          status: "New",
          createdAt: new Date().toISOString(),
        });
        event(s, `Table ${s.visit.table} · ${kind}`);
      })
    )
      notify("Your demo request is with the team.");
  }
  function saveProduct(product: Product) {
    const ok = update((s) => {
      if (!["owner", "manager"].includes(s.role || ""))
        throw new Error("Only management can edit menu items.");
      if (
        !product.name.trim() ||
        !Number.isInteger(product.price) ||
        product.price <= 0 ||
        product.price > 1000000
      )
        throw new Error(
          "Enter an item name and a price between 0.01 and 10,000 MAD.",
        );
      const index = s.products.findIndex((p) => p.id === product.id);
      if (index < 0) s.products.push(product);
      else s.products[index] = product;
      event(s, `${product.name} · menu updated`);
    }, "menu");
    if (ok) notify("Menu item saved.");
    return ok;
  }
  function reserve(reservation: Omit<Reservation, "id" | "status">) {
    const ok = update((s) => {
      if (
        !reservation.name.trim() ||
        reservation.guests < 1 ||
        reservation.guests > 12 ||
        !reservation.date ||
        !reservation.time
      )
        throw new Error("Enter your name, date, time and a party of 1–12.");
      if (
        new Date(`${reservation.date}T${reservation.time}`).getTime() <
        Date.now()
      )
        throw new Error("Choose a future reservation time.");
      if (
        s.reservations.some(
          (r) =>
            r.customer &&
            r.status === "Confirmed" &&
            r.date === reservation.date &&
            r.time === reservation.time,
        )
      )
        throw new Error("You already have a booking for this time.");
      s.reservations.unshift({
        ...reservation,
        id: uid("B"),
        status: "Confirmed",
      });
      event(s, `${reservation.name} · table booked for ${reservation.guests}`);
    });
    if (ok) notify("Your demo reservation is confirmed.");
    return ok;
  }
  function saveStaff(staff: Staff) {
    const ok = update((s) => {
      if (!["owner", "manager"].includes(s.role || ""))
        throw new Error("Only management can edit the team.");
      if (
        (staff.role === "owner" ||
          s.staff.find((p) => p.id === staff.id)?.role === "owner") &&
        s.role !== "owner"
      )
        throw new Error("Managers cannot change owners.");
      if (!staff.name.trim() || !staff.email.endsWith(".test"))
        throw new Error("Use a name and a fictional .test email.");
      const index = s.staff.findIndex((person) => person.id === staff.id);
      if (index < 0) s.staff.push(staff);
      else s.staff[index] = staff;
      event(s, `${staff.name} · team updated`);
    }, "team");
    if (ok) notify("Demo team member saved. No invitation email was sent.");
    return ok;
  }
  return (
    <Context.Provider
      value={{
        state,
        ready,
        storageError,
        toast,
        notify,
        update,
        login,
        logout: () =>
          update((s) => {
            s.role = null;
          }),
        reset: () => {
          const fresh = seedState();
          update((s) => Object.assign(s, fresh));
          notify("Demo restored to its starting state.");
        },
        addItem,
        checkout,
        progress,
        cancelOrder,
        payOrder,
        refundOrder,
        joinTable,
        closeTable,
        requestService,
        saveProduct,
        reserve,
        saveStaff,
      }}
    >
      {children}
    </Context.Provider>
  );
}
export function useDemo() {
  const value = useContext(Context);
  if (!value) throw new Error("DemoProvider is missing");
  return value;
}
