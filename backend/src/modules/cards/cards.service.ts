import { Injectable } from '@nestjs/common';
import { Repository, ILike } from 'typeorm';
import { InjectRepository } from '@nestjs/typeorm';
import { Card } from '../../entities/card.entity';

@Injectable()
export class CardsService {
  constructor(@InjectRepository(Card) private readonly repo: Repository<Card>) {}

  findAll(q?: string, suit?: string) {
    const where: any[] = [];
    
    if (q) {
      where.push({ name: ILike(`%${q}%`) });
      where.push({ keywords: ILike(`%${q}%`) });
    }
    
    if (suit) {
      return this.repo.find({ 
        where: { suit },
        order: { id: 'ASC' }
      });
    }
    
    if (where.length > 0) {
      return this.repo.find({ where, order: { id: 'ASC' } });
    }
    
    return this.repo.find({ order: { id: 'ASC' } });
  }

  findOne(id: number) {
    return this.repo.findOne({ where: { id } });
  }

  async getByShortName(nameShort: string): Promise<Card | null> {
    return this.repo.findOne({ where: { nameShort } });
  }

  async filterBySuit(suit: string): Promise<Card[]> {
    return this.repo.find({ 
      where: { suit },
      order: { id: 'ASC' }
    });
  }

  async getMajorArcana(): Promise<Card[]> {
    return this.repo.find({
      where: { arcanaType: 'Major' },
      order: { number: 'ASC' }
    });
  }

  async count() {
    return this.repo.count();
  }
}