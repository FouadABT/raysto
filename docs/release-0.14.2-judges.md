# Raysto 0.14.2 for judges (Android)

The judges' Android build is served at **https://rays.to/raysto.apk**, with its checksum and install steps on [rays.to](https://rays.to). The same file can also be attached to a GitHub release (tag `v0.14.2-judges` on `main`) with the notes below.

---

**Raysto 0.14.2 for the PayPal AI Hackathon judges.** Android, arm64. Everything runs on PayPal Sandbox: no real money moves.

The quickest way to judge Raysto needs no install: open **https://rays.to** and press **Try it now**.

### Install

1. Download `raysto-0.14.2-android-arm64.apk` (from https://rays.to/raysto.apk) on an Android phone or tablet (Android 7 or later, 64-bit).
2. Open it and allow installing from this source when Android asks.
3. Open Raysto and choose **Use my Raysto account**. Under **Hackathon judges**, tap **Sign in as a diner** or **Sign in as the café manager**.

### What to try

- **As the diner:** open *Atelier Café · Judges*, tap **Ask Raysto**, and ask for "two vegetarian lunches under $25". **Order and approve in PayPal** opens PayPal Sandbox; sign in with the Sandbox buyer from the Devpost testing instructions.
- **As the café manager:** the counter till with the PayPal QR and **Say the order** (voice ordering), the kitchen board, and the **Agents** inbox where AI proposals wait for approval.

The offline design preview (fictional data, simulated payment) sits behind **Design preview** on the first screen and is not part of the judged product.

### Changes since 0.14.0

- The diner's basket, order and payment screens use the same card design as the staff screens: lines, total, state and one next step.
- On phones, the Orders board's filters scroll in one row.
- Three older layout tests are fixed; 154 widget tests pass.

SHA-256: `5a9c3e0e7c1e1d631152b0949e6cb09d2a9617f159dac656246291ed5342ca00`

*3 November:* this build is still the one served. The source since then has a Shifts tab on the staff tablet (clock in and out), a tip step before PayPal and a "Something was wrong?" complaint sheet on paid orders; the next build will carry them. The backend and console changes of 3 November are in [release-backend-0.14.md](release-backend-0.14.md).
