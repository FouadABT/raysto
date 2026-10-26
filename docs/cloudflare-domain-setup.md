# rays.to — Cloudflare setup, in English

## Domain layout

| Hostname | Purpose |
| --- | --- |
| `rays.to` | Future landing page, isolated from the API and Awhar |
| `www.rays.to` | Permanent redirect to `https://rays.to` |
| `api.rays.to` | Serverpod API, health, reporting and payment callbacks |

The server-side configuration is installed. Public `https://api.rays.to/health` returned HTTP 200 and Raysto JSON. Valid Let's Encrypt origin certificates cover all three names. The root domain intentionally returns a temporary HTTP 503 message until the landing page is built; this is not a backend failure. No landing page was designed or published in this deployment.

## 1. Select the correct Cloudflare zone

1. Open [Cloudflare Dashboard](https://dash.cloudflare.com/).
2. Select **rays.to**.
3. Check that its status is **Active**. If it is Pending, copy the two assigned Cloudflare nameservers into the domain registrar's nameserver settings, then wait for activation. Do not copy example nameservers or change the Awhar domain.

## 2. Final DNS records

Open **DNS → Records**. Use **Add record** for a missing entry or **Edit** for an existing one:

| Type | Name | Content / Target | Final proxy status | TTL |
| --- | --- | --- | --- | --- |
| A | `@` | `13.51.45.215` | **Proxied** (orange cloud) | Auto |
| A | `api` | `13.51.45.215` | **Proxied** (orange cloud) | Auto |
| CNAME | `www` | `rays.to` | **Proxied** (orange cloud) | Auto |

`@` means the root `rays.to`. Save each record. Resolve conflicting A/AAAA/CNAME entries for those exact names rather than creating duplicates. No IPv6 origin address was configured for these domains, so an unrelated AAAA origin should not be retained. Preserve MX/TXT records used for email or verification.

During initial certificate setup, DNS-only/gray records were requested. Certificates are now issued, so **orange/Proxied is the final setting**. The record's Content remains the AWS IP even though public DNS lookups return Cloudflare addresses when proxied; that is expected.

## 3. SSL/TLS

1. Open **SSL/TLS → Overview**.
2. Select **Full (strict)** and save if needed.
3. Open **SSL/TLS → Edge Certificates** and confirm Universal SSL is active. Successful public HTTPS already demonstrates edge certificate coverage for the API.

Full (strict) validates the origin certificate. Do not use Flexible with the server's HTTP-to-HTTPS redirects: that can cause a redirect loop. No Cloudflare Origin CA certificate or private key upload is required; Let's Encrypt is already configured. Cloudflare SSL mode was not read or changed through an authenticated Cloudflare API in this task, so verify this setting in your dashboard.

The server already redirects plain HTTP to HTTPS and `www` to the root after TLS is enabled. An additional Cloudflare redirect rule is unnecessary. Keep `api.rays.to` separate; do not redirect it to the landing page.

## 4. Keep API responses out of the cache

The API origin sends `Cache-Control: no-store`. Add a narrowly scoped rule to preserve that behavior if you add broader site cache rules later:

1. Open **Caching → Cache Rules** (some dashboard layouts label this **Cache → Cache Rules**).
2. Click **Create rule**.
3. Name it **Raysto API — bypass cache**.
4. Choose **Custom filter expression**.
5. Select **Hostname**, **equals**, `api.rays.to`, or use **Edit expression**:

   ```text
   (http.host eq "api.rays.to")
   ```

6. Under **Cache eligibility**, choose **Bypass cache**.
7. Click **Deploy**. If other rules are present, ensure a later broad cache rule does not override the API bypass.

This rule applies only to the API. The future landing page can have its own caching policy. Leave unrelated Cloudflare settings at their defaults unless a real requirement appears; no special Origin Rule, custom port or URL rewrite is needed.

## 5. Verify the result

Open [API health](https://api.rays.to/health). Expected HTTP 200:

```json
{"status":"ok","service":"raysto","paymentEnvironment":"sandbox"}
```

Open [www.rays.to](https://www.rays.to): it should redirect to [rays.to](https://rays.to). The root currently displays **Raysto: the landing page is being prepared.** with HTTP 503. When we build the landing page, that isolated Nginx site will be updated without changing the API.

PowerShell checks:

```powershell
curl.exe -i https://api.rays.to/health
curl.exe -I https://www.rays.to/
nslookup api.rays.to 1.1.1.1
```

Cloudflare IPs in the DNS answer are normal for orange-cloud records. A 526 indicates origin certificate validation trouble; a repeated redirect usually means Flexible mode or a conflicting redirect rule. Check the server and SSL mode rather than weakening certificate validation.

## Server-side status and commands

The user-authorized backend is on the existing host `13.51.45.215`, with its own `raysto.service`, database `raysto_production`, users and Nginx files. No firewall port beyond the already-open 22/80/443 was added. Internal listeners 18080–18082 are protected by the existing deny-incoming firewall.

```powershell
ssh -i "C:\Users\fabat\Desktop\Awhar\modernapp\v1\awhar_backend\new-key-awhar.pem" ubuntu@13.51.45.215
```

Then on the server:

```bash
sudo systemctl status raysto --no-pager
curl http://127.0.0.1:18082/health
sudo journalctl -u raysto -n 50 --no-pager
```

Certificates renew through the existing `certbot.timer`; simulated renewal succeeded for both certificate groups. A Raysto-only deploy hook tests and reloads Nginx after renewal, without restarting Awhar. The installation script is available at `/opt/raysto/deploy/enable-tls.sh all` if certificate configuration needs to be repeated; it validates public webroot reachability first. Do not run the one-time provisioning script again or reset database credentials during routine deployments.

See [AWS operations](aws-backend.md) for paths, backups, migrations, deployment evidence and remaining provider setup.

Official references: [DNS records](https://developers.cloudflare.com/dns/manage-dns-records/how-to/create-dns-records/), [Full (strict)](https://developers.cloudflare.com/ssl/origin-configuration/ssl-modes/full-strict/), [cache rule setup](https://developers.cloudflare.com/cache/how-to/cache-rules/create-dashboard/).
