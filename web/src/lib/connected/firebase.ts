import { getApp, getApps, initializeApp } from "firebase/app";
import {
  browserSessionPersistence,
  getAuth,
  setPersistence,
} from "firebase/auth";

export async function connectedAuth() {
  const apiKey = process.env.NEXT_PUBLIC_FIREBASE_API_KEY;
  const appId = process.env.NEXT_PUBLIC_FIREBASE_APP_ID;
  if (!apiKey || !appId)
    throw new Error("Firebase web application configuration is missing.");
  const app = getApps().length
    ? getApp()
    : initializeApp({
        apiKey,
        appId,
        projectId: "raysto-38505",
        authDomain: "raysto-38505.firebaseapp.com",
        messagingSenderId: "110106610042",
        storageBucket: "raysto-38505.firebasestorage.app",
      });
  const auth = getAuth(app);
  await setPersistence(auth, browserSessionPersistence);
  return auth;
}
