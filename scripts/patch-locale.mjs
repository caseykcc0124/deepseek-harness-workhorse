import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import { fileURLToPath } from 'node:url';

export const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const read = name => JSON.parse(fs.readFileSync(path.join(root, 'localization', name), 'utf8'));
export function patch(source, map = read('zh-TW.json')) {
  if (source.includes('// workhorse-zh-TW-v1')) return source;
  let result = source.replace(/\r\n/g, '\n');
  for (const [oldText, newText] of read('replacements.json')) {
    if (result.split(oldText).length !== 2) throw new Error(`Unsupported locale source: ${oldText.slice(0, 60)}`);
    result = result.replace(oldText, () => newText);
  }
  const helper = `// workhorse-zh-TW-v1\nconst DSH_ZHTW = ${JSON.stringify(map)};\nfunction dshZhTw(value) {\n if (typeof value !== "string") return value;\n return value.replace(/[\\u3400-\\u9fff]+/g, part => DSH_ZHTW[part] ?? Array.from(part, c => DSH_ZHTW[c] ?? c).join(""));\n}\n`;
  return helper + result;
}

export function install(target) {
  const original = fs.readFileSync(target, 'utf8');
  if (original.includes('// workhorse-zh-TW-v1')) return { status: 'already-patched' };
  const hash = crypto.createHash('sha256').update(fs.readFileSync(target)).digest('hex');
  if (hash !== read('baseline.json').original_sha256) throw new Error('Locale source hash changed. Review compatibility before patching.');
  const output = patch(original);
  const backup = path.join(root, '.backups', 'client.original.js');
  fs.mkdirSync(path.dirname(backup), { recursive: true });
  if (!fs.existsSync(backup)) fs.writeFileSync(backup, original);
  fs.writeFileSync(target, output);
  return { status: 'patched', locale: 'zh-TW' };
}

if (process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  const candidates = [
    path.join(root, 'node_modules/@deepseek-ai/dsh-client-locale/lib/client.js'),
    path.join(root, 'node_modules/@deepseek-ai/dsh/node_modules/@deepseek-ai/dsh-client-locale/lib/client.js'),
  ];
  const target = process.argv[2] || candidates.find(file => fs.existsSync(file));
  if (!target) throw new Error('Install the pinned DSH package first.');
  console.log(JSON.stringify(install(target)));
}
