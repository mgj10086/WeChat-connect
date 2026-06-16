import { WSClient, type WsFrame } from '@wecom/aibot-node-sdk';
import { generateReqId } from '@wecom/aibot-node-sdk';
import { logger } from './logger.js';

export interface WeComConfig { botId: string; secret: string; }

export interface BridgeMessage {
  userId: string; chatId: string; text: string; imageUrls: string[];
  msgid: string; platform: 'wecom'; frame: WsFrame;
}

export interface WeComCallbacks { onMessage: (msg: BridgeMessage) => Promise<void>; }

export class WeComBot {
  private client: WSClient;
  constructor(private config: WeComConfig, private callbacks: WeComCallbacks) {
    this.client = new WSClient({ botId: config.botId, secret: config.secret });
  }
  connect(): void {
    this.client.connect();
    this.client.on('authenticated', () => logger.info('wecom: authenticated', { botId: this.config.botId }));
    this.client.on('message.text', (frame: WsFrame) => {
      const content = frame.body.text?.content || '';
      if (!content.trim()) return;
      this.callbacks.onMessage({
        userId: frame.body.from?.userid || '', chatId: frame.body.chatid || '',
        text: content, imageUrls: [], msgid: frame.body.msgid || '',
        platform: 'wecom', frame,
      });
    });
    this.client.on('event.enter_chat', (frame: WsFrame) => {
      this.client.replyWelcome(frame, { msgtype: 'text', text: { content: '你好，我是朏朏 ✨' } });
    });
    this.client.on('error', (err: Error) => logger.error('wecom: error', { error: err.message }));
  }
  disconnect(): void { this.client.disconnect(); }
  startStream(frame: WsFrame, text: string): string {
    const sid = generateReqId('stream'); this.client.replyStream(frame, sid, text, false); return sid;
  }
  streamChunk(frame: WsFrame, sid: string, text: string, finish: boolean): void {
    this.client.replyStream(frame, sid, text, finish);
  }
}
