import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import vm from 'node:vm';
import os from 'node:os';
import { spawnSync } from 'node:child_process';
import { patch, install, root } from './patch-locale.mjs';

const fixture = process.env.DSH_LOCALE_FIXTURE || path.join(root, '.backups/client.original.js');
test('patch the real pinned locale module, preserve syntax and be idempotent', () => {
  const original = fs.readFileSync(fixture, 'utf8');
  const result = patch(original);
  assert.equal(patch(result), result);
  assert.ok(result.includes('"zh-TW": { label: "繁體中文（台灣）", fallback: "zh" }'));
  const syntax = spawnSync(process.execPath, ['--check', '--input-type=module'], { input: result, encoding: 'utf8' });
  assert.equal(syntax.status, 0, syntax.stderr);
  const context = vm.createContext({});
  vm.runInContext(result.slice(0, result.indexOf('\n}\n') + 3), context);
  for (const [input, expected] of [
    ['设置', '設定'], ['权限', '權限'], ['智能体', '代理'],
    ['新建会话', '新增對話'], ['全局面板', '全域面板'],
    ['搜索会话', '搜尋對話'], ['保存', '儲存'],
    ['删除 {name}？', '刪除 {name}？'], ['https://example.com/api', 'https://example.com/api'],
  ]) assert.equal(context.dshZhTw(input), expected);
});
test('unknown upstream source fails closed', () => {
  assert.throws(() => patch('unexpected module'), /Unsupported locale source/);
  const temporary = fs.mkdtempSync(path.join(os.tmpdir(), 'dsh-locale-'));
  const file = path.join(temporary, 'client.js');
  fs.writeFileSync(file, 'unexpected module');
  assert.throws(() => install(file), /source hash changed/);
  assert.equal(fs.readFileSync(file, 'utf8'), 'unexpected module');
  fs.unlinkSync(file);
  fs.rmdirSync(temporary);
});
