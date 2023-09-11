import { Body, Controller, Get } from '@nestjs/common';

@Controller("healthz")
export class HealthController {
  constructor() {}

  @Get()
  healthcheck(): string {
    return "ok"
  }
}
