import type {
  AgAiHarness,
  AgAiHarnessEventListener,
  AgAiThreadSummary,
  AgAiNewThreadOptions,
  AgAiChatSession,
  AgAiChatSessionEventListener,
  AgAiChatMessage,
  AgAiRunStatus,
  AgAiSendOptions,
} from "ag-studio";
import { ConnectedApi } from "./api";
import type {
  AssistantHistory,
  AssistantResult,
  AttentionFilter,
} from "./contracts";

class Session implements AgAiChatSession {
  messages: readonly AgAiChatMessage[] = [];
  status: AgAiRunStatus = "idle";
  artifacts = [];
  private listeners = new Set<AgAiChatSessionEventListener>();
  private runId?: number;
  private closed = false;
  private generation = 0;
  private cancelRequested = false;
  constructor(
    readonly threadId: string,
    private harness: RaystoHarness,
  ) {}
  addEventListener(_type: "changed", listener: AgAiChatSessionEventListener) {
    this.listeners.add(listener);
  }
  removeEventListener(
    _type: "changed",
    listener: AgAiChatSessionEventListener,
  ) {
    this.listeners.delete(listener);
  }
  private changed() {
    for (const listener of this.listeners) listener({ type: "changed" });
    this.harness.changed();
  }
  hydrate(rows: AssistantHistory[]) {
    this.messages = rows.flatMap((row) => [
      {
        id: `user:${row.id}`,
        role: "user" as const,
        parts: [{ type: "text" as const, text: row.text }],
        createdAt: Date.parse(row.createdAt),
      },
      ...(row.answer.text
        ? [
            {
              id: `answer:${row.id}`,
              role: "assistant" as const,
              parts: [{ type: "text" as const, text: row.answer.text }],
              createdAt: Date.parse(row.createdAt),
            },
          ]
        : []),
    ]);
    const pending = rows.findLast((row) =>
      ["queued", "running"].includes(row.status),
    );
    if (pending) {
      this.runId = pending.id;
      this.status = "running";
      void this.wait(pending.id);
    }
    this.changed();
  }
  sendMessage(text: string, options?: AgAiSendOptions) {
    if (this.closed || this.status === "running" || !text.trim()) return;
    if (options?.attachments?.length) {
      this.fail("Use Raysto’s reviewed menu import for documents.");
      return;
    }
    if (text.length > 4000) {
      this.fail("Please keep your request under 4,000 characters.");
      return;
    }
    this.cancelRequested = false;
    this.status = "running";
    this.messages = [
      ...this.messages,
      {
        id: crypto.randomUUID(),
        role: "user",
        parts: [{ type: "text", text }],
        createdAt: Date.now(),
      },
    ];
    this.changed();
    const key = crypto.randomUUID();
    void this.harness.api
      .command<{ runId: number }>(
        "assistant.start",
        this.harness.tenant,
        { text, threadKey: this.threadId, locale: "en" },
        { key },
      )
      .then(async (result) => {
        this.runId = result.runId;
        if (this.cancelRequested) {
          await this.cancelRun();
          return;
        }
        await this.wait(result.runId);
      })
      .catch((error) => {
        if (!this.closed) this.fail(String(error));
      });
  }
  private async wait(id: number) {
    const generation = this.generation;
    try {
      for (
        let count = 0;
        count < 90 && !this.closed && generation === this.generation;
        count++
      ) {
        const result = await this.harness.api.query<AssistantResult>(
          "assistant.run",
          { restaurantId: this.harness.tenant, id },
        );
        if (!["queued", "running"].includes(result.status)) {
          if (!this.closed && generation === this.generation) {
            this.messages = [
              ...this.messages.filter(
                (m) =>
                  m.id !== `answer:${id}` && !m.id.startsWith(`tool:${id}:`),
              ),
              // AG Studio renders a message containing a tool call as a rail.
              // Keep each call separate so the final explanation remains visible.
              ...result.steps.map((step, index): AgAiChatMessage => ({
                id: `tool:${id}:${index}`,
                role: "assistant",
                createdAt: Date.now(),
                parts: [
                  {
                    type: "tool_call",
                    toolCall: {
                      toolCallId: `${id}:${index}`,
                      name: step.tool,
                      status:
                        step.status === "completed" ? "complete" : "error",
                      args: {},
                      result: { source: step.source },
                    },
                  },
                ],
              })),
              {
                id: `answer:${id}`,
                role: "assistant",
                createdAt: Date.now(),
                parts: [
                  {
                    type: "text",
                    text:
                      result.answer.text ??
                      (result.status === "cancelled"
                        ? "Request cancelled."
                        : "Request ended."),
                  },
                ],
              },
            ];
            this.status = result.status === "failed" ? "error" : "idle";
            this.runId = undefined;
            if (result.status === "completed" && result.answer.presentation)
              this.harness.present(
                result.answer.presentation.filter,
                result.answer.presentation.view,
              );
            this.changed();
          }
          return;
        }
        await new Promise((resolve) => setTimeout(resolve, 1000));
      }
      if (!this.closed && generation === this.generation)
        this.fail(
          "This request is still pending. Reopen the conversation to recover its result.",
        );
    } catch (error) {
      if (!this.closed && generation === this.generation)
        this.fail(String(error));
    }
  }
  private fail(text: string) {
    this.status = "error";
    this.messages = [
      ...this.messages,
      {
        id: crypto.randomUUID(),
        role: "assistant",
        parts: [{ type: "error", message: text }],
        createdAt: Date.now(),
      },
    ];
    this.changed();
  }
  cancel() {
    this.cancelRequested = true;
    void this.cancelRun().catch((error) => this.fail(String(error)));
  }
  private async cancelRun() {
    if (this.runId)
      await this.harness.api.command(
        "assistant.cancel",
        this.harness.tenant,
        {},
        { id: this.runId },
      );
  }
  close() {
    this.closed = true;
    this.generation++;
    this.listeners.clear();
  }
  reopen() {
    if (!this.closed) return;
    this.closed = false;
    if (this.runId) void this.wait(this.runId);
  }
}

/** AG Studio's real custom harness, backed by Raysto's bounded server tool loop. */
export class RaystoHarness implements AgAiHarness {
  readonly agents = [
    {
      id: "raysto",
      name: "Raysto",
      description: "Your restaurant, with the facts at hand.",
      available: true,
      userFacing: true,
    },
  ];
  readonly promptStarters = [
    {
      label: "Who is ready to pay?",
      prompt:
        "Show tables that requested the bill and still have an outstanding balance.",
    },
    {
      label: "Payment attention",
      prompt:
        "Show unresolved payment exceptions and explain what staff should review.",
    },
  ];
  threads: readonly AgAiThreadSummary[] = [];
  private sessions = new Map<string, Session>();
  private listeners = new Set<AgAiHarnessEventListener>();
  private disposed = false;
  constructor(
    readonly api: ConnectedApi,
    readonly tenant: number,
    readonly present: (
      filter: AttentionFilter,
      view?: "overview" | "payments" | "service",
    ) => void,
  ) {}
  async restore() {
    const history = await this.api.query<{ runs: AssistantHistory[] }>(
      "operations.threads",
      { restaurantId: this.tenant },
    );
    if (this.disposed) return;
    const groups = new Map<string, AssistantHistory[]>();
    for (const run of history.runs) {
      const rows = groups.get(run.threadKey) ?? [];
      rows.push(run);
      groups.set(run.threadKey, rows);
    }
    this.threads = [
      ...this.threads,
      ...[...groups]
        .filter(([id]) => !this.sessions.has(id))
        .map(([id, rows]) => ({
          threadId: id,
          agentId: "raysto",
          title: rows[0].text?.slice(0, 55) ?? "Restaurant conversation",
          updatedAt: Date.parse(rows.at(-1)!.createdAt),
        })),
    ];
    for (const [id, rows] of groups) {
      if (this.sessions.has(id)) continue;
      const session = new Session(id, this);
      this.sessions.set(id, session);
      session.hydrate(rows);
    }
    this.changed();
  }
  changed() {
    if (!this.disposed)
      for (const listener of this.listeners) listener({ type: "changed" });
  }
  addEventListener(_type: "changed", listener: AgAiHarnessEventListener) {
    this.listeners.add(listener);
  }
  removeEventListener(_type: "changed", listener: AgAiHarnessEventListener) {
    this.listeners.delete(listener);
  }
  getAgent(id: string) {
    return this.agents.find((a) => a.id === id);
  }
  getThread(id: string) {
    return this.threads.find((t) => t.threadId === id);
  }
  getSession(id: string) {
    return this.sessions.get(id);
  }
  async openThread(id: string) {
    const session = this.sessions.get(id);
    if (!session) throw new Error("Conversation unavailable.");
    session.reopen();
    return session;
  }
  async createThread(options: AgAiNewThreadOptions) {
    if (!this.getAgent(options.agentId) || this.disposed)
      throw new Error("Assistant unavailable.");
    const id = crypto.randomUUID(),
      session = new Session(id, this);
    this.sessions.set(id, session);
    this.threads = [
      ...this.threads,
      {
        threadId: id,
        agentId: "raysto",
        title: options.title,
        updatedAt: Date.now(),
      },
    ];
    this.changed();
    return session;
  }
  async deleteThread(id: string) {
    await this.api.command("operations.archiveThread", this.tenant, {
      threadKey: id,
    });
    this.sessions.get(id)?.close();
    this.sessions.delete(id);
    this.threads = this.threads.filter((t) => t.threadId !== id);
    this.changed();
  }
  dispose() {
    this.disposed = true;
    for (const s of this.sessions.values()) s.close();
    this.listeners.clear();
  }
}
