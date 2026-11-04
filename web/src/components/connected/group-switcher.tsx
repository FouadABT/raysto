"use client";
/**
 * The group switcher above the venue picker, and the choice it shares with
 * the Group section. Shown only to people in a group (`me.groups`). Picking
 * a group narrows the venue picker to that group's venues; the Group section
 * then reads that group. Kept apart from group-section.tsx so the console's
 * first screen does not load AG Studio.
 */
import { createContext, useCallback, useContext, useEffect, useMemo, useState } from "react";
import type { ConnectedApi } from "@/lib/connected/api";
import { roleLabel, venuesInChoice, type GroupRef, type GroupRow } from "@/lib/connected/group";

export { venuesInChoice };

export interface GroupChoice {
  /** The person's groups with their venues (group.list). */
  groups: GroupRow[];
  /** The group chosen in the switcher, or null for "All my restaurants". */
  groupId: number | null;
  setGroupId: (id: number | null) => void;
  /** Read the groups again (after creating one or attaching a venue). */
  reload: () => void;
}

const Choice = createContext<GroupChoice | null>(null);
export const GroupChoiceProvider = Choice.Provider;
/** The switcher's choice; null outside the console shell (the preview, tests). */
export const useGroupChoice = () => useContext(Choice);

/**
 * The groups behind the switcher. Reads group.list only when `me` listed a
 * group, so a single-venue owner never makes the call.
 */
export function useGroups(api: ConnectedApi, refs: readonly GroupRef[] | undefined) {
  const [groups, setGroups] = useState<GroupRow[]>([]);
  const [groupId, setGroupId] = useState<number | null>(null);
  const [tick, setTick] = useState(0);
  const any = (refs?.length ?? 0) > 0;
  useEffect(() => {
    if (!any && tick === 0) return;
    let live = true;
    api
      .query<{ rows: GroupRow[] }>("group.list")
      .then((r) => {
        if (!live) return;
        setGroups(r.rows);
        setGroupId((id) => (id && r.rows.some((g) => g.id === id) ? id : null));
      })
      .catch(() => live && setGroups([]));
    return () => {
      live = false;
    };
  }, [api, any, tick]);
  const reload = useCallback(() => setTick((t) => t + 1), []);
  return useMemo<GroupChoice>(() => ({ groups, groupId, setGroupId, reload }), [groups, groupId, reload]);
}

export function GroupSwitcher({
  choice,
  className,
}: {
  choice: GroupChoice;
  className: string;
}) {
  if (choice.groups.length === 0) return null;
  const group = choice.groups.find((g) => g.id === choice.groupId);
  return (
    <label className={`ops-venue ops-group-switch ${className}`}>
      <span>Group</span>
      <select
        aria-label="Group"
        value={choice.groupId ?? ""}
        onChange={(e) => choice.setGroupId(e.target.value ? Number(e.target.value) : null)}
      >
        <option value="">All my restaurants</option>
        {choice.groups.map((g) => (
          <option key={g.id} value={g.id}>
            {g.name}
          </option>
        ))}
      </select>
      <small>
        {group
          ? `${group.venues.length} venue${group.venues.length === 1 ? "" : "s"} · you are its ${roleLabel(group.role).toLowerCase()}`
          : `${choice.groups.length} group${choice.groups.length === 1 ? "" : "s"}`}
      </small>
    </label>
  );
}
