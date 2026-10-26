# PayPal sandbox connection status — 25 October 2026

Latest: [actual standalone Sandbox test, 0.7.0](paypal-real-sandbox-test.md) is deployed with a new APK. Actual unapproved checkout/retry and the approval gate passed. Buyer-approved capture and delivered webhook remain pending.

PayPal Sandbox credentials and webhook settings are now installed in the private AWS Raysto service environment. Verification completed around **04:41 UTC**. This is sandbox configuration and connection verification, not completed buyer-approved payment acceptance.

Subsequent mobile work: [reusable Flutter payment core](paypal-mobile-core.md) now supplies a connected own-order checkout adapter, recovery controller, Android return routes and a separate local test lab. The demo restaurant checkout is still separate. Buyer-approved capture, delivered webhook and physical-device acceptance remain pending.

## Configuration

| Setting | Value |
| --- | --- |
| App display name | Raysto |
| API environment | `https://api-m.sandbox.paypal.com`; gateway remains sandbox-only |
| Merchant ID | `FTPS9AY4WXNTJ`, retrieved from the app's default payee and matched to the supplied sandbox Business account email |
| Webhook | `84F063355E5284541` |
| Listener | `https://api.rays.to/webhooks/paypal` |
| Subscribed event | `PAYMENT.CAPTURE.COMPLETED` only |
| Return / cancel | `https://api.rays.to/payments/return` / `https://api.rays.to/payments/cancel` |
| Environment | `/etc/raysto/runtime.env`, root-owned `0600` inside root-only `/etc/raysto` |

The user explicitly authorized use and installation of the existing sandbox credentials after the initial preflight. Hidden terminal input and encrypted SSH stdin carried the Client ID/Secret to the server; they were not embedded in source, APKs, command-line arguments or terminal output. The sandbox account password was not needed or used. No local PayPal secret file was created.

The environment contains `PAYPAL_CLIENT_ID`, `PAYPAL_CLIENT_SECRET`, `PAYPAL_MERCHANT_ID`, `PAYPAL_WEBHOOK_ID`, `PAYPAL_RETURN_URL` and `PAYPAL_CANCEL_URL`. A root-only backup preceded the atomic update. All Firebase settings and unrelated environment fields were preserved. Only `raysto.service` was restarted; no code release, database migration, Nginx change or Awhar update was needed.

## Actual checks

| Check | Result |
| --- | --- |
| OAuth from AWS | HTTP 200, credentials accepted |
| Create one unapproved USD 1.00 sandbox order | HTTP 200; order `3V5150588J175880N`, state `PAYER_ACTION_REQUIRED` |
| Read order and discover merchant | HTTP 200; matching merchant email and valid Merchant ID |
| Approval link | HTTPS PayPal Sandbox host, appropriate payer-action relation |
| Repeat create with the same request ID | HTTP 200, same provider order ID; no second order created |
| Register webhook | Created once and read back successfully; URL and single event subscription matched |
| Running Raysto process | All six PayPal environment values matched installation; Firebase configuration preserved |
| API health | Public and origin HTTP 200 |
| Return/cancel routes | Public HTTP 200; neither route claims that a payment succeeded |
| Unsigned webhook | Public HTTP 401 `forbidden`, rather than `not_configured` |
| Firebase scheduler | One `raysto-notifications` task remained registered after restart |
| Raysto SQL payment attempts/receipts/webhook events | Zero each; the setup probe did not create SQL business/payment fixtures |
| Awhar | Active; same PID **2312912** and start **2026-10-25 03:50:16 UTC** before/after; API/site HTTP 200; original Nginx checksum matched |

Automatic approval initially rejected the bundled checkout probe. The user then explicitly approved **one unapproved USD 1.00 Sandbox order, without approval/capture or money transfer**, before execution. The standalone provider order was created solely for connection/merchant discovery and was not linked to a Raysto SQL order. No buyer approval or capture was attempted, and no money moved. It remains an unpaid sandbox test record; no deletion or cancellation was claimed. The temporary remote setup script was removed.

## Remaining payment acceptance

- Wire/verify the connected mobile checkout flow against real Raysto orders; the illustrative demo checkout is separate.
- Have a separate sandbox **Personal** buyer approve an actual connected test checkout.
- Test capture, SQL reconciliation, duplicate/retry handling and an actual delivered, signature-verified `PAYMENT.CAPTURE.COMPLETED` webhook.
- Verify mobile return/cancel behavior and interrupted-checkout recovery. The current public callback text is a neutral return page, not proof of a completed native handoff.
- Refund/dispute handling and multiple restaurant merchant onboarding are not implemented by this single-merchant sandbox setup. Live payments remain out of scope.

No further manual Merchant ID lookup or duplicate webhook registration is needed. The earlier read-only preflight/browser timeout was superseded by successful API-based setup.

References: [PayPal API setup](https://developer.paypal.com/api/get-started/), [Orders create](https://developer.paypal.com/api/orders/v2/orders-create), [webhook registration/verification](https://developer.paypal.com/api/rest/webhooks/rest/) and [sandbox account management](https://developer.paypal.com/sandbox-testing/accounts).
