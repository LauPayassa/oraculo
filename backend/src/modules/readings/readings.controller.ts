import { Controller, Post, Body, UseGuards, Request, Get, Query, Param } from '@nestjs/common';
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

  // Endpoint público para salvar leitura sem autenticação (para demo)
  @Post('save')
  async saveReading(@Body() body: { type: string; cards: any[]; spreadType: number }) {
    return this.readingsService.saveReading(null, body.type, body.cards, body.spreadType);
  }

  // Endpoint público para listar histórico (para demo)
  @Get('history')
  async publicHistory(@Query('limit') limit = 20) {
    return this.readingsService.getPublicHistory(Number(limit));
  }

  // Endpoint para buscar uma leitura específica
  @Get(':id')
  async getReading(@Param('id') id: string) {
    return this.readingsService.getReadingById(id);
  }

  @Get('daily')
  async daily(@Query('date') date?: string, @Query('userId') userId?: string) {
    const dateStr = date || new Date().toISOString().slice(0, 10);
    return this.readingsService.dailyCard(dateStr, userId);
  }

  @UseGuards(JwtAuthGuard)
  @Get('user/history')
  async history(@Request() req: any, @Query('limit') limit = 20) {
    return this.readingsService.historyForUser(req.user.id, Number(limit));
  }
}