import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import { root } from './patch-locale.mjs';
const catalog = JSON.parse(fs.readFileSync(path.join(root, 'plugins/catalog.json'), 'utf8'));
const destination = path.join(root, 'downloads');
fs.mkdirSync(destination, { recursive: true });
for (const item of catalog) {
  const response = await fetch(`https://registry.npmjs.org/${item.name}/${item.version}`);
  if (!response.ok) throw new Error(`Metadata request failed: ${item.name}`);
  const metadata = await response.json();
  const archive = await fetch(metadata.dist.tarball);
  if (!archive.ok) throw new Error(`Download failed: ${item.name}`);
  const bytes = Buffer.from(await archive.arrayBuffer());
  const [algorithm, expected] = item.npm_integrity.split('-', 2);
  if (crypto.createHash(algorithm).update(bytes).digest('base64') !== expected) throw new Error(`Integrity mismatch: ${item.name}`);
  fs.writeFileSync(path.join(destination, `${item.name}-${item.version}.tgz`), bytes);
  console.log(`Downloaded and verified ${item.name}@${item.version}; not installed or enabled`);
}
