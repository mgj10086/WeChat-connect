import { readFileSync, writeFileSync, mkdirSync, existsSync } from 'node:fs';
import { join } from 'node:path';
import { homedir } from 'node:os';
import { logger } from './logger.js';

const DATA_DIR = process.env.WCC_DATA_DIR || join(homedir(), '.wechat-claude-code');
const MEMORY_DIR = join(DATA_DIR, 'memory');

export function ensureMemoryDirs(): void { mkdirSync(MEMORY_DIR, { recursive: true }); }

export function buildMemoryContext(): { context: string; paths: string[] } {
  ensureMemoryDirs();
  const globalPath = join(MEMORY_DIR, 'global.md');
  let content = '';
  try { content = readFileSync(globalPath, 'utf-8').trim(); } catch {}
  return {
    context: content ? `\n\n---\n## 持久记忆\n\n${content}\n` : '',
    paths: [globalPath],
  };
}
