# Firebase server connection — 25 October 2026

The Firebase server credential is installed and enabled for the AWS Raysto backend. This completes the missing server authentication configuration; it does not establish notification reception on a phone or complete native application acceptance.

## Installed configuration

- Project: `raysto-38505`.
- Dedicated identity: `raysto-backend@raysto-38505.iam.gserviceaccount.com`.
- Project role: `roles/firebasecloudmessaging.admin`.
- Bucket-only role: `roles/storage.objectUser` on `raysto-38505.firebasestorage.app`. No public bucket IAM bindings were present.
- Credential: `/opt/raysto/secrets/firebase-admin.json`, owner/group `root:raysto`, mode `0640`; its directory is `0750`. The runtime identity can read but cannot write the credential. The key was transferred directly from the user's private Downloads file; it was not copied into source, APKs, docs or chat.
- `/etc/raysto/runtime.env` remains root-owned `0600`. It now sets `GOOGLE_APPLICATION_CREDENTIALS` to the above path and `RAYSTO_NOTIFICATIONS_ENABLED=true`. Existing values were preserved and a root-only environment backup was created before editing.
- Only `raysto.service` was restarted. No binary release, migration, Nginx change, global package installation, IAM grant or organization policy change was needed.

## Actual checks

Checks ran on AWS **as the `raysto` Unix user**, using the installed key and the same separate OAuth scopes used by the backend adapter.

| Check | Result |
| --- | --- |
| Firebase Messaging HTTP v1 | HTTP 200 with `validate_only: true`; authorization/request validation succeeded, no notification delivered |
| Private server Storage object upload | HTTP 200; unique temporary object, generation precondition, 44 harmless bytes |
| Read object | HTTP 200; downloaded SHA-256 matched the uploaded bytes |
| Delete object | HTTP 204; subsequent lookup HTTP 404; no live QA object remains |
| Notification queue before activation | Zero pending/total events and zero device-token rows; no existing users were messaged |
| Running service environment | Expected credential path and notifications flag read back from the actual Raysto process |
| Recurring dispatcher | One `raysto-notifications` task registered as `NotificationCallsDispatchFutureCall`, with its scheduled time advancing after startup |
| Public API | `https://api.rays.to/health` HTTP 200 after restart |
| Awhar isolation | `awhar-server.service` retained PID **2312912**, start **2026-10-25 03:50:16 UTC**, throughout this change; API/site HTTP 200; original Nginx checksum matched |

The earlier Awhar PID in deployment/hardening evidence is a historical checkpoint. A fresh baseline was recorded before this operation; Awhar was not restarted by this operation. Verification completed around **04:10 UTC**. Bucket soft-delete retention can retain a deleted object according to its existing policy; HTTP 404 confirms absence from the live object namespace, not permanent erasure of all retained versions.

Messaging used the official [validation-only request](https://firebase.google.com/docs/reference/fcm/rest/v1/projects.messages/send). The Storage probe verifies credential/IAM access, not a restaurant manager UI upload. No business records, Firebase users, public URLs or real push messages were created.

## Remaining user setup and acceptance

The temporary project override for `iam.managed.disableServiceAccountKeyCreation` was still **not enforced** at verification. Restore the original inherited protection after successful key setup:

1. Open [Raysto organization policies](https://console.cloud.google.com/iam-admin/orgpolicies?project=raysto-38505), keeping the project selector on **Raysto**.
2. Find the exact constraint `iam.managed.disableServiceAccountKeyCreation`.
3. Choose **Gérer la règle → Hériter du règlement parent → Définir des règles**. Verify the effective state returns to **Appliquée**. Do not change the organization-wide policy or delete the working key.

This constraint controls creation of new keys; existing-key deletion is a separate action. See [Google's service-account policy reference](https://docs.cloud.google.com/organization-policy/restrict-service-accounts).

Still pending:

- Actual Google account selection/return to the Android app, email verification and password-reset inbox/link completion; previously deferred by the user.
- The 0.5.3 notification opt-in, process-restart/logout cleanup and actual device reception/display checks on a working Android phone. Server validation alone does not prove any of these. The backend currently sends data messages; visible notification handling remains to be accepted as an app feature.
- Mac/Xcode native setup, signing, APNs credentials and real iOS acceptance.
- Store-signing certificate registration and device-attestation/App Check decisions before wider release.
- Dedicated profile/avatar/presence screens and full connected restaurant/order/staff/payment features remain product work. The previously verified Firebase SDK service APIs are supporting infrastructure.

No PayPal configuration was performed in this Firebase-only operation.
