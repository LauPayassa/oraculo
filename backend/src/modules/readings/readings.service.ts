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