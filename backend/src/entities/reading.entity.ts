import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, CreateDateColumn } from 'typeorm';
import { User } from './user.entity';

@Entity()
export class Reading {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @ManyToOne(() => User, (user) => user.readings, { nullable: true })
  user?: User;

  @Column()
  type!: string; // 'daily' | 'yesno' | 'custom'

  // array of { cardId, position?, reversed }
  @Column({ type: 'text' })
  cards!: string;

  @Column({ type: 'text', nullable: true })
  meta?: string;

  @Column({ type: 'boolean', default: true })
  isPrivate!: boolean;

  @CreateDateColumn()
  createdAt!: Date;
}