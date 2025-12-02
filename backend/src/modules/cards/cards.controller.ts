import { Controller, Get, Param, Query, NotFoundException } from '@nestjs/common';
import { CardsService } from './cards.service';

@Controller('api/cards')
export class CardsController {
  constructor(private readonly cards: CardsService) {}

  @Get()
  list(@Query('q') q?: string, @Query('suit') suit?: string) {
    return this.cards.findAll(q, suit);
  }

  @Get('majors')
  async getMajorArcana() {
    return this.cards.getMajorArcana();
  }

  @Get('short/:nameShort')
  async getByShortName(@Param('nameShort') nameShort: string) {
    const card = await this.cards.getByShortName(nameShort);
    if (!card) {
      throw new NotFoundException(`Carta com nameShort '${nameShort}' não encontrada`);
    }
    return card;
  }

  @Get(':id')
  async get(@Param('id') id: string) {
    const card = await this.cards.findOne(Number(id));
    if (!card) {
      throw new NotFoundException(`Carta com ID ${id} não encontrada`);
    }
    return card;
  }
}