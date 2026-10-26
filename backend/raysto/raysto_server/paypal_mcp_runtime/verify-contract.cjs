// Offline contract check of the installed official package. No payment API call.
const { spawn } = require('node:child_process');
const { createInterface } = require('node:readline');
const { join } = require('node:path');
const assert = require('node:assert/strict');

const child = spawn(process.execPath, [
  join(__dirname, 'node_modules/@paypal/mcp/dist/index.js'),
  '--tools=orders.get,payments.getRefunds',
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
const timer = setTimeout(() => finish('MCP contract deadline'), 10000);
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
      assert.deepEqual(tools, [
        { name: 'get_order', fields: ['id'], required: ['id'] },
        { name: 'get_refund', fields: ['refund_id'], required: ['refund_id'] },
      ]);
      console.log('Official PayPal MCP contract verified: get_order(id), get_refund(refund_id); no other tools.');
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
