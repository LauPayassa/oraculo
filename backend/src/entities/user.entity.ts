import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, OneToMany } from 'typeorm';
import { Reading } from './reading.entity';
import { Favorite } from './favorite.entity';
import { Note } from './note.entity';

@Entity()
export class User {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ unique: true })
  email!: string;

  @Column()
  passwordHash!: string;

  @Column({ nullable: true })
  name?: string;

  @CreateDateColumn()
  createdAt!: Date;

  @OneToMany(() => Reading, (reading) => reading.user)
  readings?: Reading[];

  @OneToMany(() => Favorite, (fav) => fav.user)
  favorites?: Favorite[];

  @OneToMany(() => Note, (note) => note.user)
  notes?: Note[];
}