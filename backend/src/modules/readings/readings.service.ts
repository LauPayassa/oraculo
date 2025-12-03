import { Injectable } from '@nestjs/common';
import { Repository } from 'typeorm';
import { Reading } from '../../entities/reading.entity';
import { InjectRepository } from '@nestjs/typeorm';
import { Card } from '../../entities/card.entity';
import * as crypto from 'crypto';

@Injectable()
export class ReadingsService {
  constructor(
    @InjectRepository(Reading) private readonly readingRepo: Repository<Reading>,
    @InjectRepository(Card) private readonly cardRepo: Repository<Card>
  ) {}

  async draw(userId: string | null, type: string, count = 3) {
    const cards = await this.cardRepo.find();
    if (cards.length === 0) throw new Error('No cards seeded');
    // shuffle deterministic using crypto random if wanted; simple shuffle here:
    const shuffled = cards.sort(() => Math.random() - 0.5).slice(0, count);
    const result = shuffled.map((c) => ({
      cardId: c.id,
      reversed: Math.random() < 0.5
    }));
    const reading = this.readingRepo.create({
      user: userId ? ({ id: userId } as any) : null,
      type,
      cards: JSON.stringify(result),
      isPrivate: true
    });
    await this.readingRepo.save(reading);
    const interpretations = result.map((r) => {
      const c = shuffled.find((s) => s.id === r.cardId)!;
      return {
        card: c,
        reversed: r.reversed,
        meaning: r.reversed ? (c.reversedMeaning || c.uprightMeaning) : c.uprightMeaning
      };
    });
    return { reading, interpretations };
  }

  async saveReading(userId: string | null, type: string, cards: any[], spreadType: number) {
    const reading = this.readingRepo.create({
      user: userId ? ({ id: userId } as any) : null,
      type: type || 'custom',
      cards: JSON.stringify(cards),
      meta: JSON.stringify({ spreadType }),
      isPrivate: false
    });
    const saved = await this.readingRepo.save(reading);
    
    // Retornar com as cartas populadas
    const cardIds = cards.map(c => c.id);
    const fullCards = await this.cardRepo.findByIds(cardIds);
    
    return {
      ...saved,
      cardsData: fullCards
    };
  }

  async getPublicHistory(limit = 20) {
    const readings = await this.readingRepo.find({
      where: { isPrivate: false },
      order: { createdAt: 'DESC' },
      take: limit
    });

    // Popular com dados das cartas
    const enriched = await Promise.all(
      readings.map(async (reading) => {
        const cardData = JSON.parse(reading.cards);
        const cardIds = cardData.map((c: any) => c.id);
        const cards = await this.cardRepo.findByIds(cardIds);
        const meta = reading.meta ? JSON.parse(reading.meta) : {};
        
        return {
          id: reading.id,
          type: reading.type,
          createdAt: reading.createdAt,
          spreadType: meta.spreadType || cardData.length,
          cards: cards,
          cardCount: cards.length
        };
      })
    );

    return enriched;
  }

  async getReadingById(id: string) {
    const reading = await this.readingRepo.findOne({ where: { id } });
    if (!reading) return null;

    const cardData = JSON.parse(reading.cards);
    const cardIds = cardData.map((c: any) => c.id);
    const cards = await this.cardRepo.findByIds(cardIds);
    const meta = reading.meta ? JSON.parse(reading.meta) : {};

    return {
      id: reading.id,
      type: reading.type,
      createdAt: reading.createdAt,
      spreadType: meta.spreadType || cardData.length,
      cards: cards
    };
  }

  async historyForUser(userId: string, limit = 20) {
    return this.readingRepo.find({ where: { user: { id: userId } }, order: { createdAt: 'DESC' }, take: limit });
  }

  async dailyCard(dateStr: string, userId?: string) {
    const cards = await this.cardRepo.find();
    const seed = crypto.createHash('sha256').update(dateStr + (userId || '')).digest('hex');
    const idx = parseInt(seed.slice(0, 8), 16) % cards.length;
    const card = cards[idx];
    return { card, reversed: false, meaning: card.uprightMeaning };
  }
}