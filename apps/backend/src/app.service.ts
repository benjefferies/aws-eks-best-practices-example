import { Injectable } from '@nestjs/common';

@Injectable()
export class AppService {

  private messages: string[] = []  // Change to be 

  getMessages(): string[] {
    return this.messages;
  }

  addMessage(message: string): void {
    this.messages.push(message);
  }
}
