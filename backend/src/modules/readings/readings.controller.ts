import { Controller, Post, Body, UseGuards, Request, Get, Query } from '@nestjs/common';
import { ReadingsService } from './readings.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

@Controller('api/readings')
export class ReadingsController {
  constructor(private readonly readingsService: ReadingsService) {}

  @UseGuards(JwtAuthGuard)
  @Post('draw')
  async draw(@Request() req: any, @Body() body: { count?: number; type?: string }) {
    const userId = req.user?.id || null;
    return this.readingsService.draw(userId, body.type || 'custom', body.count || 3);
  }

  @Get('daily')
  async daily(@Query('date') date?: string, @Query('userId') userId?: string) {
    const dateStr = date || new Date().toISOString().slice(0, 10);
    return this.readingsService.dailyCard(dateStr, userId);
  }

  @UseGuards(JwtAuthGuard)
  @Get('history')
  async history(@Request() req: any, @Query('limit') limit = 20) {
    return this.readingsService.historyForUser(req.user.id, Number(limit));
  }
}