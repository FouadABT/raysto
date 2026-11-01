import {
  EmailAuthProvider,
  GoogleAuthProvider,
  reauthenticateWithCredential,
  reauthenticateWithPopup,
} from "firebase/auth";
import type { ConnectedApi } from "./api";
import { connectedAuth } from "./firebase";

/** Whether the signed-in manager confirms with a password (else Google). */
export async function usesPassword(): Promise<boolean> {
  const user = (await connectedAuth()).currentUser;
  return !!user?.providerData.some((p) => p.providerId === "password");
}

/**
 * Confirms the signed-in manager again and records a short-lived step-up on
 * the server, as the app does before a refund or release.
 */
export async function stepUp(
  api: ConnectedApi,
  restaurantId: number,
  password?: string,
): Promise<void> {
  const user = (await connectedAuth()).currentUser;
  if (!user) throw new Error("Sign in again to continue.");
  if (password !== undefined) {
    await reauthenticateWithCredential(
      user,
      EmailAuthProvider.credential(user.email ?? "", password),
    );
  } else {
    await reauthenticateWithPopup(user, new GoogleAuthProvider());
  }
  await api.command("identity.stepUp", restaurantId, {
    firebaseIdToken: await user.getIdToken(true),
  });
}
