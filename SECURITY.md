# Security

Raysto is a development preview. The `main` branch is the current review target; there is no supported production release or guarantee that the full acceptance matrix has passed.

## Report privately

Use [GitHub private vulnerability reporting](https://github.com/FouadABT/raysto/security/advisories/new). Include the affected commit, prerequisites, minimal reproduction and impact. Redact credentials and personal data. Do not post exploits against the hosted service or another person's records in public issues.

Testing permission applies to your own isolated checkout and test accounts. This repository does not authorize scanning other tenants, unrelated services or shared production infrastructure.

## Credential boundaries

PayPal secrets, Firebase service-account private keys, database passwords, JWT signing material and AWS/SSH keys belong in ignored local configuration or a deployment secret store, never in the mobile bundle or repository.

Checked-in Firebase mobile configuration identifies the application and project; it is distinct from a service-account key. Firebase service API keys are public client identifiers. Access depends on rules, identity, App Check and appropriate key restrictions. See [Firebase's guidance](https://firebase.google.com/docs/projects/api-keys).

If a secret is committed, revoke/rotate it first, then remove it from history. Deleting the latest file does not invalidate the credential.

See [security/state contracts](docs/backend-v2/security-and-states.md) and [remaining acceptance work](docs/project-status.md). Selected tests do not replace an independent production review.
