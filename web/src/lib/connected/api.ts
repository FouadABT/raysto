import type { Auth, User } from "firebase/auth";
import type { Json } from "./contracts";

export class ApiFailure extends Error {
  constructor(
    public code: string,
    message: string,
  ) {
    super(message);
  }
}

/** Backend credentials live in this instance only, never local/session storage. */
export class ConnectedApi {
  private token?: string;
  private exchange?: Promise<void>;
  private ended = false;
  constructor(
    private auth: Auth,
    private user: User,
  ) {}
  close() {
    this.ended = true;
    this.token = undefined;
  }
  private current() {
    if (this.ended || this.auth.currentUser !== this.user)
      throw new ApiFailure("session_changed", "Sign in again.");
  }
  private async credentials(force = false): Promise<Headers> {
    this.current();
    const proof = await this.user.getIdToken(force);
    this.current();
    if (!this.token) {
      this.exchange ??= (async () => {
        const response = await fetch("/api/raysto/auth/firebase", {
          method: "POST",
          cache: "no-store",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ firebaseIdToken: proof }),
        });
        const payload = await response.json();
        if (!response.ok)
          throw new ApiFailure(
            payload.error?.code ?? "sign_in_failed",
            payload.error?.message ?? "Could not sign in.",
          );
        this.current();
        this.token = payload.data.token;
      })().finally(() => {
        this.exchange = undefined;
      });
      await this.exchange;
    }
    this.current();
    return new Headers({
      Authorization: `Bearer ${this.token}`,
      "X-Raysto-Firebase-Token": proof,
      "Content-Type": "application/json",
    });
  }
  async request<T>(
    path: string,
    init: RequestInit = {},
    retry = true,
  ): Promise<T> {
    const headers = await this.credentials();
    const response = await fetch(`/api/raysto/${path}`, {
      ...init,
      headers,
      cache: "no-store",
      signal: init.signal ?? AbortSignal.timeout(45000),
    });
    this.current();
    if (response.status === 401 && retry) {
      this.token = undefined;
      await this.credentials(true);
      return this.request<T>(path, init, false);
    }
    const payload = await response.json();
    this.current();
    if (!response.ok)
      throw new ApiFailure(
        payload.error?.code ?? "request_failed",
        payload.error?.message ?? "Request could not be completed.",
      );
    return payload.data as T;
  }
  query<T>(name: string, params: Json = {}, signal?: AbortSignal) {
    const query = new URLSearchParams();
    for (const [key, value] of Object.entries(params))
      if (value != null) query.set(key, String(value));
    return this.request<T>(`queries/${encodeURIComponent(name)}?${query}`, {
      signal,
    });
  }
  command<T>(
    name: string,
    restaurantId: number,
    data: Json = {},
    options: { id?: number; version?: number; key?: string } = {},
  ) {
    // A caller retrying a mutation must retain options.key; never auto-retry a new business request.
    return this.request<T>(`commands/${encodeURIComponent(name)}`, {
      method: "POST",
      body: JSON.stringify({
        requestKey: options.key ?? crypto.randomUUID(),
        restaurantId,
        resourceId: options.id,
        expectedVersion: options.version,
        dataJson: JSON.stringify(data),
      }),
    });
  }
  async stream(
    path: string,
    signal: AbortSignal,
    receive: (event: Json) => void,
    retry = true,
  ): Promise<void> {
    const headers = await this.credentials();
    headers.set("Accept", "text/event-stream");
    const response = await fetch(`/api/raysto/${path}`, {
      headers,
      signal,
      cache: "no-store",
    });
    this.current();
    if (response.status === 401 && retry) {
      await response.body?.cancel();
      this.token = undefined;
      await this.credentials(true);
      return this.stream(path, signal, receive, false);
    }
    if (!response.ok || !response.body)
      throw new ApiFailure("stream_failed", "Live connection interrupted.");
    const reader = response.body
      .pipeThrough(new TextDecoderStream())
      .getReader();
    let buffer = "";
    try {
      while (!signal.aborted) {
        const { done, value } = await reader.read();
        if (done) break;
        this.current();
        buffer += value.replace(/\r/g, "");
        if (buffer.length > 1048576)
          throw new Error("Event exceeded its limit.");
        let end: number;
        while ((end = buffer.indexOf("\n\n")) >= 0) {
          const frame = buffer.slice(0, end);
          buffer = buffer.slice(end + 2);
          const data = frame
            .split("\n")
            .filter((l) => l.startsWith("data:"))
            .map((l) => l.slice(5).trimStart())
            .join("\n");
          if (data) {
            this.current();
            receive(JSON.parse(data));
          }
        }
      }
    } finally {
      await reader.cancel().catch(() => {});
    }
  }
}
