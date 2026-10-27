# Device acceptance and restaurant pilot

This is an execution checklist, not a record of successful tests. Physical-device and participant results remain pending. Use PayPal Sandbox only.

## Before the session

1. Install the current ARM64 Android candidate from the release handoff. Check its version and SHA-256 against that handoff. This development-signed candidate is for direct testing, not a Play Store release.
2. Choose **connected** mode. The separate offline demo cannot prove real AI, payments, notifications or cross-device delivery.
3. Prepare two diners and an assigned waiter using separate authenticated sessions. A manager opens [the operations console](https://ops.rays.to/ops). Obtain the private QA sign-in details from the project owner; never publish credentials in a recording or repository.
4. Use the explicitly labelled QA restaurant and menu. A test visit must have two admitted diners, an appointed host and the assigned waiter. A printed table QR alone does not grant admission.
5. Keep two **Personal** Sandbox buyer accounts available. These are separate from Firebase identities and from the merchant's Business account. The owner provides their local credentials-file path or enters them personally on PayPal.
6. Enable Android notifications. For the Google login check, the phone owner selects their own Google account; no password or authorization code is sent to the assistant.

## One connected journey

| Step | Action | Evidence to record |
| --- | --- | --- |
| Identity | Sign in with Google on the phone; enter the authorized visit. | Device/Android/app version, successful connected session. |
| Audience | Ask each diner who can read the room and where private help goes. | Their answer, without prompting the correct answer. |
| Live room | Diner A sends a message; diner B and waiter observe it. Background one phone, send another message, then reopen. | Consistent history, notification received, authorized deep link. |
| Group decision | Ask Raysto for a vegetarian meal for two with a shared starter within $30 on the QA menu. | Actual tool names, quote, unknown dietary facts kept unknown. |
| Approval | The host reviews the exact basket and confirms. Try confirming from the other diner first. | Correct host restriction, one submitted order, kitchen/console agreement. |
| Service | Request the bill; waiter acknowledges it. | Room delivery differs from staff acknowledgement; dashboard attention filter matches. |
| First share | Ask for an equal split; first diner reviews and approves their share on the **real PayPal Sandbox page**. | Provider capture, backend receipt, verified webhook, updated shared balance. |
| Second share | Second diner approves their remaining frozen share. | No double settlement; final balance agrees on both phones and console. |
| Recovery | On a separate checkout, interrupt the app return after provider approval, reopen the existing checkout and reconcile. | Same checkout ID, no replacement charge, one verified outcome. |
| Refund | Authorized staff request one partial refund against a verified capture. | Provider refund and ledger agree; cancellation credit stays separate. |
| Console | Save a selected table, payment tab, attention filter and widget arrangement; reload. | Correct restored selection, authorized room and current totals. |

Do not mark a payment successful from a return URL, browser screenshot or AI response alone. Retain sanitized provider/ledger references privately and publish only the necessary evidence.

## Three short usability sessions

Invite diners and restaurant staff who consent to participate. Aim for three small sessions; disclose the actual number and prior experience. These sessions are a usability pilot, not a statistically reliable performance claim.

- Let one group do the manual flow first and another do the AI-assisted flow first. Use comparable menus and budgets; record the order to expose learning effects.
- Time from presenting the task to agreement on the reviewed basket. Count basket corrections and staff clarification requests.
- Record whether each payer settled successfully, how many attempts were needed and whether participants understood the room audience and individual approval.
- Ask: “What surprised you?”, “Where did you hesitate?” and “What would you change before using this in a restaurant?”
- Obtain separate permission before recording or quoting. Avoid collecting unnecessary personal details; use participant codes.
- Report failures and aborted sessions. Do not replace measured times with estimates or present scripted QA as customer research.

Use [the pilot results sheet](pilot-results.csv). Blank values mean **not yet observed**, not zero. Keep identifiable notes and recordings outside the public repository.

## Owner dependencies

- Local path to the two Personal Sandbox buyers' credentials file, or personal approval of both checkouts.
- Android phone, two diner sessions and one waiter session; notify the engineer when ready for the coordinated check.
- AG Studio trial extension through December 15. The currently supplied key expires December 10; send the replacement's file path and expiry when issued.
- Three recruited pilot sessions and permission to use any resulting quotations. The owner produces the submission video after the journey works.
