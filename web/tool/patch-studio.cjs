/** AG Studio 3.0.0 integration correction. Keep the installed licence notices. */
const fs = require('node:fs');
const path = require('node:path');
const crypto = require('node:crypto');
const guards = [
  ['isBlockStillWanted(startRow, generation) {\n    if (generation !== this.refreshGeneration) {',
   'isBlockStillWanted(startRow, generation) {\n    if (!this.isAlive() || !this.api || generation !== this.refreshGeneration) {'],
  ['pollTimer = setInterval(() => {\n            if (this.isBlockStillWanted(startRow, generation)) {',
   'pollTimer = setInterval(() => {\n            if (!this.isAlive()) { controller.abort("destroyed"); return; }\n            if (this.isBlockStillWanted(startRow, generation)) {'],
];
function patchBundle(source) {
  for (const [before, after] of guards) {
    if (source.includes(after)) continue;
    if (source.split(before).length !== 2) throw Error('Studio teardown patch does not match the pinned bundle. Review the package before building.');
    source = source.replace(before, after);
  }
  return source;
}
module.exports = { patchBundle };
if (require.main === module) {
  const packageRoot = path.resolve(__dirname, '../node_modules/ag-studio');
  if (JSON.parse(fs.readFileSync(path.join(packageRoot, 'package.json'), 'utf8')).version !== '3.0.0') throw Error('Revalidate the Studio teardown patch for this version.');
  const result = [];
  for (const name of ['main.esm.mjs', 'main.cjs.js']) {
    const file = path.join(packageRoot, 'dist/package', name);
    const source = fs.readFileSync(file, 'utf8'), patched = patchBundle(source);
    if (source !== patched) fs.writeFileSync(file, patched, 'utf8');
    result.push({ bundle: name, sha256: crypto.createHash('sha256').update(patched).digest('hex') });
  }
  console.log('Validated Studio 3.0.0 teardown correction:', JSON.stringify(result));
}
