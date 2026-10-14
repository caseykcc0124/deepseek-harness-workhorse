import path from 'node:path';
import fs from 'node:fs';
import { spawn } from 'node:child_process';
import { root } from './patch-locale.mjs';
const home = path.join(root, '.dsh-home');
fs.mkdirSync(home, { recursive: true });
const child = spawn(process.execPath, [path.join(root, 'node_modules/@deepseek-ai/dsh/lib/bin.js'), 'web', ...process.argv.slice(2)], {
  cwd: root, stdio: 'inherit',
  env: { ...process.env, DSH_HOME: home, PATH: [path.dirname(process.execPath), path.join(root, 'node_modules/.bin'), process.env.PATH].join(path.delimiter) },
});
child.on('error', error => { console.error(error.message); process.exitCode = 1; });
child.on('exit', code => { process.exitCode = code ?? 1; });
