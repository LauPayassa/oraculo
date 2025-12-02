import { Entity, PrimaryGeneratedColumn, ManyToOne, CreateDateColumn, Column } from 'typeorm';
import { User } from './user.entity';
import { Card } from './card.entity';

@Entity()
export class Favorite {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @ManyToOne(() => User, (user) => user.favorites)
  user!: User;

  @ManyToOne(() => Card)
  card!: Card;

  @CreateDateColumn()
  createdAt!: Date;
}