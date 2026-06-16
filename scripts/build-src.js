const fs = require('fs');
const path = require('path');

const BASE = 'C:/Users/Administrator/AppData/Local/Temp/wechat-claude-src';

// 1. Patch main.ts
let c = fs.readFileSync(path.join(BASE, 'src/main.ts'), 'utf8');

// Add import
c = c.replace(
  "import { buildMemoryContext, initMemoryFiles } from './memory.js';",
  "import { buildMemoryContext, initMemoryFiles } from './memory.js';\nimport { WeComBot, type BridgeMessage } from './wecom-bot.js';"
);

// Add WeCom env check before monitor.run + remove duplicate braces
c = c.replace(
  "  logger.info('Daemon started', { accountId: account.accountId });\n  console.log(`已启动 (账号: ${account.accountId})`);\n\n  await monitor.run();",
  "  logger.info('Daemon started', { accountId: account.accountId });\n  console.log('已启动 (个人微信账号: ' + account.accountId + ')');\n\n  const wecomBotId = process.env.WECOM_BOT_ID;\n  const wecomSecret = process.env.WECOM_BOT_SECRET;\n  if (wecomBotId && wecomSecret) {\n    startWeComChannel(config, session, sessionStore, wecomBotId, wecomSecret);\n  }\n\n  await monitor.run();"
);

fs.writeFileSync(path.join(BASE, 'src/main.ts'), c);
console.log('main.ts: imports + WeCom startup -> OK');

// 2. Append WeCom handler at end
const wecomCode = `

// ---------------------------------------------------------------------------
// 企业微信通道
// ---------------------------------------------------------------------------

function startWeComChannel(config, session, sessionStore, botId, secret) {
  const bot = new WeComBot({ botId, secret }, {
    onMessage: async (msg) => {
      logger.info('wecom msg', { userId: msg.userId, text: msg.text.slice(0, 100) });
      await processWeComMessage(msg, config, session, sessionStore, bot);
    },
  });
  bot.connect();
  logger.info('WeCom bot started', { botId });
  console.log('企业微信已启动 (' + botId + ')');
  return bot;
}

let wecomStreamCounter = 0;

async function processWeComMessage(msg, config, session, sessionStore, bot) {
  const text = msg.text;
  if (!text) return;
  const cwd = (session.workingDirectory || config.workingDirectory).replace(/^~/, require('os').homedir());
  const streamId = 's' + (++wecomStreamCounter);
  let buffer = '';
  let anySent = false;
  try {
    const { claudeQuery } = require('./claude/provider.js');
    const result = await claudeQuery({
      prompt: text, cwd, model: 'deepseek-v4-flash[1m]',
      systemPrompt: [config.systemPrompt, buildMemoryContext().context].filter(Boolean).join('\\n') || undefined,
      onText: async (delta) => {
        buffer += delta;
        if (buffer.length >= 80) { bot.streamChunk(msg.frame, streamId, buffer, false); anySent = true; buffer = ''; }
      },
      onBlockEnd: async () => {
        if (buffer.trim()) { bot.streamChunk(msg.frame, streamId, buffer, false); anySent = true; buffer = ''; }
      },
    });
    const finalText = result.text || result.error || 'ok';
    bot.streamChunk(msg.frame, streamId, finalText, true);
  } catch (err) {
    bot.streamChunk(msg.frame, streamId, 'error: ' + (err instanceof Error ? err.message : String(err)), true);
  }
}
`;

fs.appendFileSync(path.join(BASE, 'src/main.ts'), wecomCode);
console.log('main.ts: WeCom handler appended -> OK');

// 3. Compile
const { execSync } = require('child_process');
execSync('npx tsc', { cwd: BASE, stdio: 'inherit' });
console.log('tsc build -> OK');
