# Create the two Sandbox buyers

These Personal test accounts pay the restaurant's Business test account. No real card/bank or real money is needed. They are separate from Firebase/Raysto identities and your developer login.

1. Open [PayPal Developer Sandbox Accounts](https://developer.paypal.com/dashboard/accounts) and sign in with your normal developer account.
2. Select **Testing Tools → Sandbox Accounts → Create Account**.
3. Choose **Personal**, then **United States** for this USD demonstration. If a custom form appears, keep the account Personal and give it a test balance.
4. Create it. Open the account row's **… → View/Edit Account** (sometimes **View details**).
5. Under **Profile**, find the generated test email/password. Under **Funding**, confirm a Sandbox balance. Do not add a real card or bank.
6. Repeat for a second Personal account. Keep the existing Business merchant unchanged.
7. Save the two test emails/passwords outside the repository, for example `C:\Users\fabat\Downloads\raysto-sandbox-buyers.txt`, labelled Buyer 1 and Buyer 2. Send only the file path. Alternatively, approve the checkouts yourself when opened.

At checkout use the generated Personal buyer, not the developer login or seller email. Verify the page is on `sandbox.paypal.com` or `www.sandbox.paypal.com` and shows USD 13.50. Sign out/use separate sessions between buyers. Raysto confirms payment from its backend, not from the return page alone.

[Official PayPal account instructions](https://developer.paypal.com/sandbox-testing/accounts/).
