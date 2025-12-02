import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ReadingsService } from './readings.service';
import { ReadingsController } from './readings.controller';
import { Reading } from '../../entities/reading.entity';
import { Card } from '../../entities/card.entity';
import { JwtStrategy } from '../auth/jwt.strategy';
import { User } from '../../entities/user.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Reading, Card, User])],
  providers: [ReadingsService, JwtStrategy],
  controllers: [ReadingsController]
})
export class ReadingsModule {}