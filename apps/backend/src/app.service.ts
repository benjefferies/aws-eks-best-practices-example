import { Injectable } from '@nestjs/common';

@Injectable()
export class AppService {

  private messages: string[] = []  // Change to be database

  getMessages(): string[] {
    return this.messages;
  }

  addMessage(message: string): void {
    this.messages.push(message);
    return this.messages
  }
}
