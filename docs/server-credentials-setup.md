# Raysto: obtain Firebase server and PayPal sandbox credentials

Prepared 25 October 2026 for Firebase project **raysto-38505** and backend **https://api.rays.to**. Keep secrets in local private files and send only their paths in chat. The agent can then install them securely using the SSH access already authorized. Mobile `google-services.json` and `GoogleService-Info.plist` are different files; they are not server credentials.

Firebase server setup is now completed and verified on AWS; see [Firebase server verification](firebase-server-verification.md). Do not generate another key to repeat these steps. Restore the temporary project key-creation policy exception as described there. [PayPal sandbox setup](paypal-sandbox-status.md) is also installed and connection-tested on AWS, using the existing credentials with the user's explicit authorization. The Merchant ID was retrieved through the API and the webhook registered. The instructions below are a historical setup guide; no additional credential file, Merchant ID lookup or duplicate webhook is currently needed. Buyer-approved payment acceptance remains pending.

## 1. Firebase: create a dedicated backend identity

1. Open [Google Cloud service accounts for Raysto](https://console.cloud.google.com/iam-admin/serviceaccounts?project=raysto-38505). Confirm the project selector says **raysto-38505**.
2. Click **Create service account**.
3. Name: **Raysto backend**. Service account ID: **raysto-backend**. Click **Create and continue**.
4. In the role selector, search for **Firebase Cloud Messaging API Admin** and choose `roles/firebasecloudmessaging.admin`. Do not choose the similarly named legacy Firebase Cloud Messaging Admin role. This gives the server the HTTP v1 sending permission. Do not grant Owner or Editor. [Official FCM roles](https://docs.cloud.google.com/iam/docs/roles-permissions/firebasecloudmessaging).
5. Continue, leave the optional user-access section empty, and finish creating the service account.
6. Its email should be **raysto-backend@raysto-38505.iam.gserviceaccount.com**. Copy this email for the next section; it is an identifier, not a private key.
7. Open [Firebase Cloud Messaging API settings](https://console.cloud.google.com/apis/library/fcm.googleapis.com?project=raysto-38505). If the API is disabled, click **Enable**. If it is already enabled, leave it enabled. Android uses HTTP v1; no legacy server key is needed.

## 2. Firebase Storage: scope access to the Raysto bucket

1. Open [Cloud Storage buckets for Raysto](https://console.cloud.google.com/storage/browser?project=raysto-38505).
2. Open **raysto-38505.firebasestorage.app**.
3. Select **Permissions → Grant access**.
4. New principal: **raysto-backend@raysto-38505.iam.gserviceaccount.com**.
5. Select **Storage Object User** (`roles/storage.objectUser`) and save. Grant it on this bucket, not on the whole project. This permits server object operations without giving bucket or IAM administration. [Official Storage roles](https://docs.cloud.google.com/storage/docs/access-control/iam-roles).

Do not make the bucket public or loosen Firebase rules. Mobile personal uploads already work through verified-owner rules. This separate role is for trusted backend uploads. The backend does not currently require broad Firestore or Firebase Authentication administration permissions.

## 3. Download the Firebase server JSON

1. Return to [Raysto service accounts](https://console.cloud.google.com/iam-admin/serviceaccounts?project=raysto-38505).
2. Click the **Raysto backend** account you just created.
3. Select **Keys → Add key → Create new key → JSON → Create**.
4. The browser downloads a JSON file. Keep it private. If an organization policy blocks key creation, report that message; do not disable the policy.
5. Using File Explorer, create **C:\Users\fabat\.config\Raysto** and move the downloaded file there, naming it **firebase-admin.json**. An alternative private location outside this project is fine; provide its actual path.

Tell the agent only:

```text
Firebase file: C:\Users\fabat\.config\Raysto\firebase-admin.json
```

Do not paste the JSON, upload it as a chat attachment, put it in the Flutter assets, or commit it. Exported service-account JSON is supported for non-Google servers such as AWS. [Official Firebase server setup](https://firebase.google.com/docs/admin/setup).

## 4. PayPal: create a Sandbox application

1. Open [PayPal Developer Apps & Credentials](https://developer.paypal.com/dashboard/applications) and sign in to your PayPal developer account.
2. Select **Sandbox**, not Live.
3. Click **Create App**.
4. App name: **Raysto Sandbox**. Choose a **Merchant** app if the UI asks for a type, and select a Sandbox **Business** account as the merchant.
5. Create the app. Its details page displays a **Client ID** and a **Secret**; reveal the secret when needed. Save them into the private local environment file described below, never into chat.

Use the sandbox business account associated with this exact app throughout the next steps. A sandbox buyer uses a separate Personal account. PayPal requires a Business account for integrations going live and for testing outside the US; follow any account eligibility prompts rather than switching to Live. [Official PayPal getting started](https://developer.paypal.com/api/get-started/).

## 5. Find the sandbox merchant ID

1. In the developer dashboard, go to **Testing Tools → Sandbox Accounts**.
2. Find the **Business** account selected for your app.
3. Use its menu (**… → View/Edit Account**) to see its sandbox sign-in details. These are test-account credentials, different from the API Client ID/Secret.
4. Open [PayPal Sandbox](https://www.sandbox.paypal.com/) in a separate/private browser session and sign in with that **sandbox Business account**, not your normal PayPal account.
5. Open the profile/settings menu → **Account Settings → Business information**. Copy **PayPal Merchant ID** into the environment file. This is not the business account email, Client ID, app ID, or Webhook ID. [PayPal merchant-ID instructions](https://developer.paypal.com/platforms/checkout/save-payment-methods/onboarding/platform/).

## 6. Register the webhook

The agent can perform this step using the PayPal API once the private credentials and Merchant ID are supplied. The instructions below are the manual alternative; do not create a duplicate webhook if the agent already registered the same URL for this app.

1. Return to **Apps & Credentials → Sandbox → Raysto Sandbox** in the developer dashboard.
2. Find **Sandbox Webhooks** and select **Add Webhook**.
3. Listener URL: **https://api.rays.to/webhooks/paypal**.
4. Select **PAYMENT.CAPTURE.COMPLETED** only. The current backend reconciles completed captures; refund/dispute and other lifecycle webhook workflows are not implemented yet.
5. Save. Copy the resulting **Webhook ID** into the environment file.

Use that exact URL, with no extra path or trailing placeholder. The webhook ID is required for signature verification. Until the credentials are installed, the listener may return `not_configured`; that is expected and not proof of successful payment processing. [Official webhook setup](https://developer.paypal.com/api/rest/webhooks/rest/).

## 7. Save the PayPal values privately

1. Open Notepad on your computer.
2. Copy this template and replace the four placeholder values with the real values from the same sandbox app/business account:

```dotenv
PAYPAL_CLIENT_ID=REPLACE_WITH_SANDBOX_CLIENT_ID
PAYPAL_CLIENT_SECRET=REPLACE_WITH_SANDBOX_CLIENT_SECRET
PAYPAL_MERCHANT_ID=REPLACE_WITH_SANDBOX_BUSINESS_MERCHANT_ID
PAYPAL_WEBHOOK_ID=REPLACE_WITH_SANDBOX_WEBHOOK_ID
PAYPAL_RETURN_URL=https://api.rays.to/payments/return
PAYPAL_CANCEL_URL=https://api.rays.to/payments/cancel
```

3. Save as **C:\Users\fabat\.config\Raysto\paypal-sandbox.env**. In Notepad's Save As dialog, choose **All files**, not Text Documents, so Windows does not append `.txt`. Enable File Explorer's file extensions to confirm the filename if necessary.
4. Send only the path:

```text
PayPal file: C:\Users\fabat\.config\Raysto\paypal-sandbox.env
```

You do not need to create a long-lived OAuth access token. The backend exchanges the Client ID and Secret for short-lived tokens itself and uses the sandbox API host.

## 8. Prepare a sandbox buyer for approval testing

In **Testing Tools → Sandbox Accounts**, keep a separate **Personal** account available. Use its sandbox credentials yourself when approving a test checkout. Do not send its password in chat. We must use an actual sandbox buyer approval to test capture and real webhook delivery; the webhook simulator alone is insufficient. [Sandbox account types](https://developer.paypal.com/sandbox-testing/accounts).

## What the agent will do after receiving the file paths

Validate the selected Firebase project and required field presence without displaying values. Transfer the files over the authorized SSH connection, keep the Firebase key readable only by root and the Raysto service identity, merge PayPal settings into Raysto's existing root-only environment, and restart **raysto.service only**. Awhar's credentials, service, database and Nginx site must remain unchanged. Then verify real FCM authorization/private server upload access and PayPal sandbox authentication/webhook configuration before attempting an isolated sandbox purchase flow. Installing credentials alone does not prove checkout, mobile notification display, or iOS delivery.

iOS push additionally needs your Apple Developer APNs configuration and a Mac/device validation; the Firebase server JSON does not replace APNs setup.
