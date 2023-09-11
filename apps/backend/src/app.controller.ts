import { Body, Controller, Get, Post } from '@nestjs/common';
import { AppService } from './app.service';

@Controller("messages")
export class AppController {
  constructor(private readonly appService: AppService) {}

  @Get()
  getMessages(): string[] {
    return this.appService.getMessages();
  }

  @Post()
  addMessage(@Body() payload: {message: string}): string[] {  
    this.appService.addMessage(payload.message);
    return this.appService.getMessages()
  }
}
