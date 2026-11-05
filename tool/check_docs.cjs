// Before the freeze: the documents a judge reads must describe what exists.
// Fails on retired claims, unfilled placeholders, or a missing judge path.
//   node tool/check_docs.cjs
const fs = require('node:fs');
const path = require('node:path');

const root = path.resolve(__dirname, '..');
const docs = ['README.md', 'docs/devpost-submission.md', 'docs/reviewer-guide.md', 'docs/getting-started.md', 'docs/technical-overview.md'];
const retired = [
  [/0\.11\.5/, 'an old app version'],
  [/no public APK/i, 'the APK is on the releases page'],
  [/until live acceptance is recorded/i, 'acceptance is recorded'],
  [/capacity errors/i, 'Gemini billing is on'],
  [/134 widget tests|122 backend tests|14 tests for the console/, 'old test counts'],
  [/\bRender\b/, 'Render is not used'],
  [/Node\.js 22/, 'the console needs Node 24'],
  [/\{\{[A-Z_]+\}\}/, 'an unfilled placeholder'],
];
const required = {
  // Since 5 November the README is product-first; the detail lives in docs/technical-overview.md.
  'README.md': [/https:\/\/rays\.to/, /Enter the live demo/, /How PayPal and AI work together/, /## Proof/, /technical-overview\.md/],
  'docs/technical-overview.md': [/How PayPal is used/, /Tools used, and how/, /## The AI coworkers/],
  'docs/devpost-submission.md': [/https:\/\/rays\.to/, /Testing instructions/, /paypal-mcp-server/],
  'docs/reviewer-guide.md': [/rays\.to/, /AI Action Inbox/, /Enter the live demo/],
};

let failures = 0;
for (const doc of docs) {
  const text = fs.readFileSync(path.join(root, doc), 'utf8');
  for (const [pattern, why] of retired) {
    const line = text.split('\n').findIndex((l) => pattern.test(l));
    if (line >= 0) {
      failures++;
      console.log(`${doc}:${line + 1}: retired claim (${why})`);
    }
  }
  for (const pattern of required[doc] ?? []) {
    if (!pattern.test(text)) {
      failures++;
      console.log(`${doc}: missing ${pattern}`);
    }
  }
  // Relative links must point at files that exist.
  for (const [, target] of text.matchAll(/\]\((?!https?:|#|mailto:)([^)#\s]+)/g)) {
    if (!fs.existsSync(path.join(root, path.dirname(doc), target))) {
      failures++;
      console.log(`${doc}: broken link ${target}`);
    }
  }
}
console.log(failures ? `${failures} problem(s)` : 'Documents match the product.');
process.exitCode = failures ? 1 : 0;
