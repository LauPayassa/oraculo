import { Entity, PrimaryGeneratedColumn, Column } from 'typeorm';

@Entity()
export class Card {
  @PrimaryGeneratedColumn()
  id!: number;

  @Column()
  name!: string;

  @Column({ unique: true, nullable: true })
  nameShort?: string; // ex: "ar01", "swac"

  @Column()
  arcanaType!: string; // Major | Minor

  @Column({ nullable: true })
  suit?: string; // pentacles, cups, swords, wands

  @Column({ nullable: true })
  number?: number;

  @Column({ nullable: true })
  value?: string; // ace, 2, king, etc

  @Column({ type: 'text' })
  uprightMeaning!: string;

  @Column({ type: 'text', nullable: true })
  reversedMeaning?: string;

  @Column({ type: 'text', nullable: true })
  description?: string;

  @Column({ type: 'text', nullable: true })
  keywords?: string;

  @Column({ nullable: true })
  imageUrl?: string;
}