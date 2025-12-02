import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AuthModule } from './modules/auth/auth.module';
import { CardsModule } from './modules/cards/cards.module';
import { ReadingsModule } from './modules/readings/readings.module';
import { User } from './entities/user.entity';
import { Card } from './entities/card.entity';
import { Reading } from './entities/reading.entity';
import { Favorite } from './entities/favorite.entity';
import { Note } from './entities/note.entity';

@Module({
  imports: [
    TypeOrmModule.forRoot({
      type: 'sqlite',
      database: process.env.DATABASE_PATH || 'oraculo.db',
      entities: [User, Card, Reading, Favorite, Note],
      synchronize: true
    }),
    TypeOrmModule.forFeature([User, Card, Reading, Favorite, Note]),
    AuthModule,
    CardsModule,
    ReadingsModule
  ],
  controllers: [],
  providers: []
})
export class AppModule {}