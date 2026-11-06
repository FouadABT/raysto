/** Consistent, native modal for discarding drafts. Never approves a business action. */
let active: Promise<boolean> | undefined;
export function confirmDiscard(
  message = "Your unsaved changes will be discarded.",
): Promise<boolean> {
  if (active) return Promise.resolve(false);
  const opener = document.activeElement as HTMLElement | null;
  active = new Promise<boolean>((resolve) => {
    const dialog = document.createElement("dialog");
    dialog.className = "ops-confirm";
    dialog.setAttribute("aria-labelledby", "discard-title");
    dialog.setAttribute("aria-describedby", "discard-description");
    const title = document.createElement("h2");
    title.id = "discard-title";
    title.textContent = "Discard these changes?";
    const text = document.createElement("p");
    text.id = "discard-description";
    text.textContent = message;
    const actions = document.createElement("div");
    actions.className = "ops-confirm-actions";
    const stay = document.createElement("button");
    stay.type = "button";
    stay.textContent = "Keep editing";
    stay.autofocus = true;
    const discard = document.createElement("button");
    discard.type = "button";
    discard.textContent = "Discard changes";
    discard.className = "destructive";
    const finish = (result: boolean) => {
      dialog.close();
      dialog.remove();
      active = undefined;
      if (opener?.isConnected) opener.focus();
      resolve(result);
    };
    stay.onclick = () => finish(false);
    discard.onclick = () => finish(true);
    dialog.oncancel = (e) => {
      e.preventDefault();
      finish(false);
    };
    dialog.onclick = (e) => {
      if (e.target === dialog) {
        const r = dialog.getBoundingClientRect();
        if (
          e.clientX < r.left ||
          e.clientX > r.right ||
          e.clientY < r.top ||
          e.clientY > r.bottom
        )
          finish(false);
      }
    };
    actions.append(stay, discard);
    dialog.append(title, text, actions);
    document.body.append(dialog);
    dialog.showModal();
    stay.focus();
  });
  return active;
}
