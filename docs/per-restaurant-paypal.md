# Each restaurant's own PayPal account

Release 0.16, stream S6. This page covers how a café's money reaches its own PayPal account, what works today, what still needs PayPal, and how the secrets are kept.

## Routing

For each restaurant, every PayPal call uses the first account in this list that is ready:

1. **The café's own PayPal app** (path B below).
2. **Its Connect with PayPal partner connection** (path A), when PayPal confirmed it in the last 24 hours.
3. **Raysto's shared Sandbox merchant**, for the cafés listed in `RAYSTO_SANDBOX_RESTAURANT_ID` (the judges' demo cafés).
4. **Nothing.** The café cannot take PayPal payments, and checkout says so.

The routing covers these calls:

- Checkout create, read and capture, and refunds. Each checkout records the mode it was taken with (`ownApp`, `singleMerchantSandbox` or `marketplace`) and is never moved to another account.
- Pay links.
- Payouts for bills, wages, tips, suppliers and drivers. Each batch records the app that sent it, and is polled with that app.
- Invoicing through the PayPal MCP server, for catering and payment requests.
- Transaction Search, used by the daily close, the expenses agent, the accountant and analytics.
- Disputes.
- The assistant's PayPal payment check.

One restaurant's keys are never used for another restaurant. One PayPal app can be connected to only one restaurant.

## Path B: use my own PayPal app (works today, Sandbox)

Where: the console, under **Money › PayPal account**. Only the owner can do this. The phone shows the same status read-only, under **More › PayPal account**.

1. The owner opens Apps & Credentials on developer.paypal.com (Sandbox), then picks or creates an app.
2. The owner pastes the app's **Client ID** and **Secret**. They can also give the PayPal merchant ID, but this is optional.
3. The owner passes the identity check. By default this is multi-factor, the same as the partner connection. A deployment whose owners have no second factor can set `RAYSTO_MERCHANT_APP_STEP_UP=recent_auth`, which accepts a fresh sign-in instead.
4. Raysto asks PayPal Sandbox for a token with those keys. Nothing is stored unless PayPal accepts them. Wrong keys get "PayPal Sandbox did not accept this Client ID and Secret".
5. Raysto seals the secret and stores it (see Security below).
6. Raysto registers a webhook on that app for the events it handles:
   - checkout;
   - captures and refunds;
   - payout batches;
   - disputes;
   - paid and cancelled invoices.

   The webhook address is `https://api.rays.to/api/v2/webhooks/paypal-app/{opaque id}`. If PayPal says the address already exists, Raysto reuses that webhook.
7. Raysto runs a feature checklist. These are read-only probes with the café's keys, one each for:
   - Orders;
   - Refunds;
   - Payouts;
   - Invoicing;
   - Transaction Search;
   - Disputes.

   A 403 `NOT_AUTHORIZED` from PayPal shows as "Not enabled in your PayPal app", with a link to switch the feature on. **Check again** re-runs the probes. It also registers the webhook if that failed before.
8. Raysto learns the PayPal merchant ID from PayPal itself: the `account_number` in Transaction Search, or the payee of the café's first order. Nothing is created just to find it out.

The owner can **Disconnect** the app. Raysto first removes its webhook from the app at PayPal, then erases the sealed secret. The café then falls back to the next account in the routing list.

Changing or removing the app is refused in two cases:

- while a checkout taken through it is still open;
- while a payout it sent is still open.

Those belong to that app and could not be finished with another one.

## Path A: Connect with PayPal (ready, needs PayPal's partner approval)

`merchant.connect` sends the seller to PayPal through Partner Referrals. `merchant.refresh` reads the result.

- **When Raysto is approved,** the seller comes back to `PAYPAL_ONBOARDING_RETURN_URL` and the console re-checks the connection. PayPal's `MERCHANT.ONBOARDING.COMPLETED` webhook also marks the connection ready or restricted, without the owner. `MERCHANT.PARTNER-CONSENT.REVOKED` marks it revoked.
- **Today,** PayPal answers Raysto's Sandbox app with 403 `NOT_AUTHORIZED`. `deploy/ec2/probe-partner-referrals.py` recorded this, and `PAYPAL_PLATFORM_*` is not configured in production. The console and the app therefore say "Needs PayPal's partner approval for Raysto. Until then, use your own PayPal app." No connection is shown as working.

## Security

- **Sealing.** The secret is sealed with AES-256-GCM under `RAYSTO_MERCHANT_SECRET_KEY` (32 random bytes, base64), which exists only on the server.
  - Every save draws a new 96-bit nonce.
  - The associated data binds the ciphertext to its restaurant, environment, client ID and key version. A sealed secret copied to another row does not open.
- **The key is made on the server.** `deploy/ec2/activate-backend-0160.py` generates it the first time and writes it only to `/etc/raysto/runtime.env`. It never prints it and never replaces an existing one.
- **Rotating the key.** Rotation is a deliberate step: set a new key and bump `RAYSTO_MERCHANT_SECRET_KEY_VERSION`. Each owner then saves their app keys again, because until they do, their PayPal calls fail with "save the keys again". They never fall back to another account.
- **Where the secret never appears:**
  - any query or command response;
  - the audit log;
  - error messages and logs;
  - the browser after saving (the form clears it);
  - the phone, which only shows a status.

  The idempotency receipt keeps only a SHA-256 fingerprint of the request. The status shows the client ID's last four characters.
- **Tokens.** Access tokens for an app are cached in memory per app and key version. They are dropped five minutes before they expire, and after any failed call.
- **Webhooks.** An own app's webhook is verified with that app's keys and its own webhook ID. An address that is unknown or retired (after a change or a removal) answers 404. Events are accepted only for the café's own records. For example, an approval for another café's order is refused as a channel mismatch, and an invoice event must name one of the café's own invoices.
- **Live mode.** This deployment is Sandbox-only. Saving keys is refused unless `RAYSTO_PAYPAL_ENVIRONMENT=sandbox`.

## The second demo café

To give the second demo café its own Sandbox business account:

1. Fouad creates a Sandbox business account and a REST app for it on developer.paypal.com.
2. He signs in to the console as that café's owner and opens **Money › PayPal account**.
3. He pastes the app's Client ID and Secret.

The keys go from his browser to Raysto's server only. They never go through chat, the repository, or an app build.

## Settings

| Setting | Where | Purpose |
| --- | --- | --- |
| `RAYSTO_MERCHANT_SECRET_KEY` | backend, generated on the server | Seals own-app secrets |
| `RAYSTO_MERCHANT_SECRET_KEY_VERSION` | backend, optional (default 1) | Marks a deliberate key rotation |
| `RAYSTO_MERCHANT_APP_STEP_UP` | backend, optional | `recent_auth` accepts a fresh sign-in instead of MFA |
| `PAYPAL_ONBOARDING_RETURN_URL` | backend, optional | Where PayPal sends a seller back after Connect with PayPal |
| `RAYSTO_PUBLIC_API_URL` | backend, existing | Base of the webhook address (default `https://api.rays.to`) |

The migration is `20261104152814507`. It adds the table `raysto_merchant_app` and drops nothing.
