// Offline contract check of the installed official package. No payment API call.
const { spawn } = require('node:child_process');
const { createInterface } = require('node:readline');
const { join } = require('node:path');
const assert = require('node:assert/strict');

const child = spawn(process.execPath, [
  join(__dirname, 'node_modules/@paypal/mcp/dist/index.js'),
  '--tools=orders.get,payments.getRefunds,transactions.list,invoices.list,invoices.get,disputes.list,disputes.get,invoices.create,invoices.send,invoices.sendReminder,invoices.generateQRC,disputes.create',
  '--paypal-environment=sandbox',
], {
  env: {
    ...(process.platform === 'win32' ? { SystemRoot: process.env.SystemRoot } : {}),
    PAYPAL_ACCESS_TOKEN: 'offline-contract-fixture',
    PAYPAL_ENVIRONMENT: 'SANDBOX',
    NODE_OPTIONS: '--max-old-space-size=128',
  },
});
let finished = false;
// The server needs 10-15 s to start on a loaded build machine; the check is
// offline, so a generous deadline costs nothing when it passes.
const timer = setTimeout(() => finish('MCP contract deadline'), 60000);
function finish(error) {
  if (finished) return;
  finished = true;
  clearTimeout(timer);
  child.kill();
  if (error) {
    console.error(error);
    process.exitCode = 1;
  }
}
child.stderr.resume();
child.on('error', () => finish('MCP process failed'));
child.on('exit', () => { if (!finished) finish('MCP exited before verification'); });
const send = message => child.stdin.write(JSON.stringify({ jsonrpc: '2.0', ...message }) + '\n');
child.stdin.on('error', () => finish('MCP input closed'));
createInterface({ input: child.stdout }).on('line', line => {
  try {
    const message = JSON.parse(line);
    if (message.id === '1') {
      assert.equal(message.result.protocolVersion, '2025-03-26');
      send({ method: 'notifications/initialized', params: {} });
      send({ id: '2', method: 'tools/list', params: {} });
    } else if (message.id === '2') {
      const tools = message.result.tools.map(tool => ({
        name: tool.name,
        fields: Object.keys(tool.inputSchema.properties),
        required: tool.inputSchema.required,
      })).sort((a, b) => a.name.localeCompare(b.name));
      // Exactly the pinned tool list: seven reads the agents may use as
      // evidence, five changes that only an approved action runs.
      const expected = {
        accept_dispute_claim: ['dispute_id', 'note'],
        create_invoice: ['currency_code', 'primary_recipients', 'items'],
        generate_invoice_qr_code: ['invoice_id'],
        get_dispute: ['dispute_id'],
        get_invoice: ['invoice_id'],
        get_order: ['id'],
        get_refund: ['refund_id'],
        list_disputes: ['page', 'page_size'],
        list_invoices: ['page', 'page_size'],
        list_transactions: ['start_date', 'end_date'],
        send_invoice: ['invoice_id'],
        send_invoice_reminder: ['invoice_id'],
      };
      assert.deepEqual(tools.map(t => t.name), Object.keys(expected));
      for (const tool of tools) {
        for (const field of expected[tool.name]) assert.ok(tool.fields.includes(field), `${tool.name} lacks ${field}`);
      }
      // The two evidence reads keep their strict one-field contract.
      assert.deepEqual(tools.find(t => t.name === 'get_order'), { name: 'get_order', fields: ['id'], required: ['id'] });
      assert.deepEqual(tools.find(t => t.name === 'get_refund'), { name: 'get_refund', fields: ['refund_id'], required: ['refund_id'] });
      console.log('Official PayPal MCP contract verified: ' + Object.keys(expected).join(', ') + '; no other tools.');
      finish();
    }
  } catch (_) {
    finish('Official PayPal MCP protocol or tool schema changed');
  }
});
send({ id: '1', method: 'initialize', params: {
  protocolVersion: '2025-03-26', capabilities: {},
  clientInfo: { name: 'raysto-contract-check', version: '1.0.0' },
} });
