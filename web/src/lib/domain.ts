export type Role = "owner" | "manager" | "waiter" | "kitchen" | "courier";
export type Channel = "Dine-in" | "Pickup" | "Delivery";
export type OrderStatus =
  | "New"
  | "Accepted"
  | "Preparing"
  | "Ready"
  | "Out for delivery"
  | "Completed"
  | "Cancelled";
export type PaymentStatus = "Unpaid" | "Paid" | "Refunded";
export interface Product {
  id: string;
  name: string;
  description: string;
  category: string;
  price: number;
  image: string;
  tags: string[];
  allergens: string;
  available: boolean;
  featured?: boolean;
}
export interface CartLine {
  id: string;
  productId: string;
  name: string;
  price: number;
  quantity: number;
  option: string;
  note: string;
  image: string;
}
export interface Order {
  id: string;
  guest: string;
  channel: Channel;
  table?: number;
  visitId?: string;
  lines: CartLine[];
  subtotal: number;
  fee: number;
  discount: number;
  tip: number;
  total: number;
  status: OrderStatus;
  payment: PaymentStatus;
  createdAt: string;
  address: string;
  courier?: string;
  customer: boolean;
  events: { label: string; time: string }[];
}
export interface Table {
  id: number;
  seats: number;
  zone: string;
  status: "Available" | "Occupied" | "Reserved" | "Needs reset";
  visitId?: string;
  guests: number;
  x: number;
  y: number;
}
export interface Reservation {
  id: string;
  name: string;
  guests: number;
  date: string;
  time: string;
  status: "Confirmed" | "Seated" | "Cancelled" | "No-show";
  customer?: boolean;
}
export interface Request {
  id: string;
  table: number;
  kind: string;
  status: "New" | "Acknowledged" | "Completed";
  createdAt: string;
}
export interface Staff {
  id: string;
  name: string;
  email: string;
  role: Role;
  active: boolean;
}
export interface DemoState {
  version: 1;
  role: Role | null;
  products: Product[];
  orders: Order[];
  tables: Table[];
  reservations: Reservation[];
  requests: Request[];
  staff: Staff[];
  cart: CartLine[];
  favorites: string[];
  channel: Channel;
  visit: { id: string; table: number; guests: number } | null;
  settings: {
    restaurant: string;
    description: string;
    address: string;
    phone: string;
    open: boolean;
    delivery: boolean;
    pickup: boolean;
    deliveryFee: number;
    minimum: number;
    reducedMotion: boolean;
    dark: boolean;
  };
  profile: { name: string; email: string; address: string };
  activity: { id: string; text: string; time: string }[];
  waitlist: { id: string; name: string; guests: number; status: string }[];
  reviews: { orderId: string; rating: number; note: string }[];
}
export const money = (cents: number) =>
  new Intl.NumberFormat("en-MA", {
    style: "currency",
    currency: "MAD",
    maximumFractionDigits: 2,
  }).format(cents / 100);
export const roles: Role[] = [
  "owner",
  "manager",
  "waiter",
  "kitchen",
  "courier",
];
export const roleNames: Record<Role, string> = {
  owner: "Restaurant owner",
  manager: "Manager",
  waiter: "Waiter",
  kitchen: "Kitchen",
  courier: "Courier",
};
export const rolePeople: Record<Role, string> = {
  owner: "Yasmine",
  manager: "Adam",
  waiter: "Lina",
  kitchen: "Omar",
  courier: "Sami",
};
export const permissions: Record<Role, string[]> = {
  owner: [
    "overview",
    "orders",
    "kitchen",
    "tables",
    "menu",
    "reservations",
    "requests",
    "deliveries",
    "payments",
    "team",
    "reports",
    "settings",
    "storefront",
    "billing",
    "activity",
  ],
  manager: [
    "overview",
    "orders",
    "kitchen",
    "tables",
    "menu",
    "reservations",
    "requests",
    "deliveries",
    "payments",
    "team",
    "reports",
    "settings",
    "storefront",
    "activity",
  ],
  waiter: [
    "overview",
    "orders",
    "tables",
    "requests",
    "reservations",
    "activity",
  ],
  kitchen: ["kitchen", "menu", "activity"],
  courier: ["deliveries", "activity"],
};
export function can(role: Role | null, section: string) {
  return !!role && permissions[role].includes(section);
}
export function calculate(
  lines: CartLine[],
  channel: Channel,
  deliveryFee: number,
  tip = 0,
  coupon = false,
) {
  const subtotal = lines.reduce(
    (sum, line) => sum + line.price * line.quantity,
    0,
  );
  const discount = coupon ? Math.round(subtotal * 0.1) : 0;
  const fee = channel === "Delivery" ? deliveryFee : 0;
  return {
    subtotal,
    discount,
    fee,
    tip,
    total: subtotal - discount + fee + tip,
  };
}
export const nextStatus: Partial<Record<OrderStatus, OrderStatus>> = {
  New: "Accepted",
  Accepted: "Preparing",
  Preparing: "Ready",
  "Out for delivery": "Completed",
};
export function advanceOrder(order: Order, role: Role): OrderStatus {
  if (order.status === "Cancelled" || order.status === "Completed")
    throw new Error("This order is already closed.");
  if (role === "courier") {
    if (order.channel !== "Delivery" || order.courier !== "Sami")
      throw new Error("This delivery is not assigned to you.");
    if (order.status === "Ready") return "Out for delivery";
    if (order.status === "Out for delivery") return "Completed";
    throw new Error("Wait until the kitchen marks this order ready.");
  }
  if (role === "kitchen" && !["Accepted", "Preparing"].includes(order.status))
    throw new Error("Kitchen can prepare accepted tickets only.");
  if (role === "waiter" && order.status !== "Ready")
    throw new Error("Waiters can mark ready orders served.");
  if (order.status === "Ready") {
    if (order.channel === "Delivery") return "Out for delivery";
    return "Completed";
  }
  return nextStatus[order.status]!;
}
export function validateCheckout(state: DemoState, address: string) {
  if (!state.settings.open)
    throw new Error("The restaurant is paused. Your basket is saved.");
  if (!state.cart.length)
    throw new Error("Add something delicious to your basket first.");
  for (const line of state.cart) {
    const product = state.products.find((p) => p.id === line.productId);
    if (!product?.available)
      throw new Error(
        `${line.name} is no longer available. Remove it from your basket to continue.`,
      );
    const expected = product.price + (line.option === "Large" ? 2500 : 0);
    if (line.price !== expected)
      throw new Error(
        `${line.name} has a new price. Remove it and add it again.`,
      );
  }
  if (
    state.channel === "Dine-in" &&
    (!state.visit ||
      !state.tables.some(
        (t) =>
          t.id === state.visit!.table &&
          t.visitId === state.visit!.id &&
          t.status === "Occupied",
      ))
  )
    throw new Error("Join an available table before placing a dine-in order.");
  if (state.channel === "Delivery") {
    if (!state.settings.delivery)
      throw new Error("Delivery is currently paused.");
    if (!address.trim().toLowerCase().includes("casablanca"))
      throw new Error(
        "Demo delivery is available in Casablanca. Include the city in your address.",
      );
    if (
      calculate(state.cart, state.channel, state.settings.deliveryFee)
        .subtotal < state.settings.minimum
    )
      throw new Error(
        `Delivery has a ${money(state.settings.minimum)} minimum.`,
      );
  }
  if (state.channel === "Pickup" && !state.settings.pickup)
    throw new Error("Pickup is currently paused.");
}
export function seedState(): DemoState {
  const now = new Date();
  const stamp = (minutes: number) =>
    new Date(now.getTime() - minutes * 60000).toISOString();
  const products: Product[] = [
    {
      id: "p1",
      name: "Burrata garden bowl",
      description:
        "Creamy burrata, heirloom tomatoes, garden leaves and a bright basil dressing.",
      category: "Starters",
      price: 8500,
      image: "salad_bowl.jpg",
      tags: ["Vegetarian", "Popular"],
      allergens: "Milk. Other allergens are not verified.",
      available: true,
      featured: true,
    },
    {
      id: "p2",
      name: "Sunday tomato pasta",
      description:
        "Slow-roasted tomatoes, fresh basil and parmesan. The kind of comfort worth slowing down for.",
      category: "Mains",
      price: 11000,
      image: "tomato_pasta.jpg",
      tags: ["Vegetarian", "Chef’s pick"],
      allergens: "Wheat, milk. Other allergens are not verified.",
      available: true,
      featured: true,
    },
    {
      id: "p3",
      name: "Wood-fired margherita",
      description:
        "A 48-hour dough, San Marzano tomato, fior di latte and fresh basil.",
      category: "Pizza",
      price: 9500,
      image: "wood_fired_pizza.jpg",
      tags: ["Vegetarian", "Bestseller"],
      allergens: "Wheat, milk. Other allergens are not verified.",
      available: true,
      featured: true,
    },
    {
      id: "p4",
      name: "Harvest grain salad",
      description:
        "Seasonal greens, toasted grains, avocado and our house lemon dressing.",
      category: "Starters",
      price: 7500,
      image: "salad_bowl.jpg",
      tags: ["Plant-based"],
      allergens: "Ask the team; cross-contact information is unknown.",
      available: true,
    },
    {
      id: "p5",
      name: "Spicy arrabbiata",
      description:
        "Penne with a slow-cooked tomato sauce, red chili and a little extra warmth.",
      category: "Mains",
      price: 9800,
      image: "tomato_pasta.jpg",
      tags: ["Spicy", "Plant-based"],
      allergens: "Wheat. Other allergens are not verified.",
      available: true,
    },
    {
      id: "p6",
      name: "Truffle mushroom pizza",
      description:
        "Roasted mushrooms, mozzarella and fragrant truffle oil on our signature dough.",
      category: "Pizza",
      price: 13500,
      image: "wood_fired_pizza.jpg",
      tags: ["Vegetarian"],
      allergens: "Wheat, milk. Other allergens are not verified.",
      available: true,
    },
    {
      id: "p7",
      name: "Mint & lemon cooler",
      description:
        "Fresh mint, pressed lemon and sparkling water. Made to refresh.",
      category: "Drinks",
      price: 3500,
      image: "",
      tags: ["Alcohol-free"],
      allergens: "Ask the team; allergen information is unknown.",
      available: true,
    },
    {
      id: "p8",
      name: "Orange blossom lemonade",
      description:
        "House lemonade with a delicate touch of Moroccan orange blossom.",
      category: "Drinks",
      price: 3800,
      image: "",
      tags: ["Alcohol-free"],
      allergens: "Ask the team; allergen information is unknown.",
      available: true,
    },
    {
      id: "p9",
      name: "Pistachio cream dessert",
      description:
        "A little spoonful of something special. Pistachio cream and biscuit crumble.",
      category: "Desserts",
      price: 5500,
      image: "",
      tags: ["Contains nuts"],
      allergens: "Nuts, milk, wheat. Other allergens are not verified.",
      available: false,
    },
  ];
  const orders: Order[] = Array.from({ length: 18 }, (_, i) => {
    const p = products[i % 6];
    const channel: Channel = ["Dine-in", "Pickup", "Delivery"][
      i % 3
    ] as Channel;
    const quantity = (i % 3) + 1;
    const lines: CartLine[] = [
      {
        id: `seed-${i}`,
        productId: p.id,
        name: p.name,
        price: p.price,
        quantity,
        option: "Regular",
        note: i === 2 ? "No extra chili, please." : "",
        image: p.image,
      },
    ];
    return {
      id: `RS-${1048 - i}`,
      guest: [
        "Amine B.",
        "Sofia R.",
        "Mehdi A.",
        "Nora K.",
        "Alex M.",
        "Inès D.",
      ][i % 6],
      channel,
      table: channel === "Dine-in" ? [2, 4, 7][i % 3] : undefined,
      visitId: channel === "Dine-in" ? `visit-${[2, 4, 7][i % 3]}` : undefined,
      lines,
      ...calculate(lines, channel, 1500),
      status: (i < 3
        ? "New"
        : i < 5
          ? "Preparing"
          : i < 7
            ? "Ready"
            : "Completed") as OrderStatus,
      payment: i < 4 ? "Unpaid" : "Paid",
      createdAt: stamp(i < 7 ? i * 4 + 2 : 60 + (i - 7) * 29),
      address: channel === "Delivery" ? "24 Rue des Oliviers, Casablanca" : "",
      courier: channel === "Delivery" ? "Sami" : undefined,
      customer: false,
      events: [{ label: "Order placed", time: stamp(i * 4 + 2) }],
    };
  });
  return {
    version: 1,
    role: null,
    products,
    orders,
    tables: Array.from({ length: 12 }, (_, i) => ({
      id: i + 1,
      seats: i % 4 === 0 ? 6 : i % 3 === 0 ? 2 : 4,
      zone: i < 8 ? "Main room" : "Terrace",
      status: [2, 4, 7].includes(i + 1)
        ? "Occupied"
        : i === 5
          ? "Reserved"
          : i === 10
            ? "Needs reset"
            : "Available",
      visitId: [2, 4, 7].includes(i + 1) ? `visit-${i + 1}` : undefined,
      guests: [2, 4, 7].includes(i + 1) ? 2 : 0,
      x: (i % 4) * 25,
      y: Math.floor(i / 4) * 32,
    })),
    reservations: [
      {
        id: "B-101",
        name: "Léa Martin",
        guests: 4,
        date: now.toISOString().slice(0, 10),
        time: "19:00",
        status: "Confirmed",
      },
      {
        id: "B-102",
        name: "Karim Bennani",
        guests: 2,
        date: now.toISOString().slice(0, 10),
        time: "19:30",
        status: "Confirmed",
      },
      {
        id: "B-103",
        name: "Sarah & friends",
        guests: 6,
        date: now.toISOString().slice(0, 10),
        time: "20:00",
        status: "Confirmed",
      },
    ],
    requests: [
      {
        id: "R-1",
        table: 2,
        kind: "Water refill",
        status: "New",
        createdAt: stamp(3),
      },
      {
        id: "R-2",
        table: 7,
        kind: "The bill, please",
        status: "Acknowledged",
        createdAt: stamp(8),
      },
    ],
    staff: roles.map((role, i) => ({
      id: `s${i}`,
      name: rolePeople[role],
      email: `${role}@raysto.test`,
      role,
      active: true,
    })),
    cart: [],
    favorites: [],
    channel: "Pickup",
    visit: null,
    settings: {
      restaurant: "Olive & Hearth",
      description:
        "Seasonal plates. Good company. A little Mediterranean soul in the heart of Casablanca.",
      address: "24 Rue des Oliviers, Casablanca",
      phone: "+212 522 000 000",
      open: true,
      delivery: true,
      pickup: true,
      deliveryFee: 1500,
      minimum: 8000,
      reducedMotion: false,
      dark: false,
    },
    profile: {
      name: "Alex Morgan",
      email: "alex@raysto.test",
      address: "18 Boulevard Anfa, Casablanca",
    },
    activity: [
      {
        id: "a1",
        text: "Lunch service is open. Have a wonderful shift.",
        time: stamp(90),
      },
    ],
    waitlist: [],
    reviews: [],
  };
}
