#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="Oraculo"
echo "Criando pasta do projeto em ./${ROOT_DIR}"
rm -rf "${ROOT_DIR}"
mkdir -p "${ROOT_DIR}/backend/src/seeds"
mkdir -p "${ROOT_DIR}/backend/src/modules/auth"
mkdir -p "${ROOT_DIR}/backend/src/modules/cards"
mkdir -p "${ROOT_DIR}/backend/src/modules/readings"
mkdir -p "${ROOT_DIR}/backend/src/modules/users"
mkdir -p "${ROOT_DIR}/backend/src/modules/favorites"
mkdir -p "${ROOT_DIR}/backend/src/modules/notes"
mkdir -p "${ROOT_DIR}/backend/src/entities"
mkdir -p "${ROOT_DIR}/frontend/src/app/components/login"
mkdir -p "${ROOT_DIR}/frontend/src/app/components/draw"
mkdir -p "${ROOT_DIR}/frontend/src/app/services"
mkdir -p "${ROOT_DIR}/frontend/src/environments"
mkdir -p "${ROOT_DIR}/frontend/src/assets/cards"

echo "Criando backend/package.json"
cat > "${ROOT_DIR}/backend/package.json" <<'EOF'
{
  "name": "oraculo-backend",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "start": "nest start",
    "start:dev": "nest start --watch",
    "build": "nest build",
    "seed:cards": "ts-node -r tsconfig-paths/register src/seeds/seed-cards.ts"
  },
  "dependencies": {
    "@nestjs/common": "^9.0.0",
    "@nestjs/core": "^9.0.0",
    "@nestjs/jwt": "^9.0.0",
    "@nestjs/passport": "^9.0.0",
    "@nestjs/platform-express": "^9.0.0",
    "bcrypt": "^5.0.1",
    "class-transformer": "^0.5.1",
    "class-validator": "^0.14.0",
    "passport": "^0.6.0",
    "passport-jwt": "^4.0.0",
    "pg": "^8.8.0",
    "reflect-metadata": "^0.1.13",
    "rxjs": "^7.8.0",
    "typeorm": "^0.3.17"
  },
  "devDependencies": {
    "@nestjs/cli": "^9.0.0",
    "@nestjs/schematics": "^9.0.0",
    "@nestjs/testing": "^9.0.0",
    "@types/bcrypt": "^5.0.0",
    "@types/node": "^18.0.0",
    "ts-node": "^10.9.1",
    "typescript": "^4.9.5"
  }
}
EOF

echo "Criando backend/.env.example"
cat > "${ROOT_DIR}/backend/.env.example" <<'EOF'
# Backend env example
PORT=3000
DATABASE_HOST=postgres
DATABASE_PORT=5432
DATABASE_USER=oraculo
DATABASE_PASSWORD=oraculo_password
DATABASE_NAME=oraculo_db
JWT_SECRET=change_this_secret
JWT_EXPIRATION=3600s
EOF

echo "Criando backend/tsconfig.json"
cat > "${ROOT_DIR}/backend/tsconfig.json" <<'EOF'
{
  "compilerOptions": {
    "module": "commonjs",
    "declaration": false,
    "removeComments": true,
    "emitDecoratorMetadata": true,
    "experimentalDecorators": true,
    "target": "es2019",
    "sourceMap": true,
    "outDir": "./dist",
    "baseUrl": "./",
    "incremental": true,
    "skipLibCheck": true
  },
  "exclude": ["node_modules", "dist"]
}
EOF

echo "Criando backend/src/main.ts"
cat > "${ROOT_DIR}/backend/src/main.ts" <<'EOF'
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import * as dotenv from 'dotenv';
dotenv.config();

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.enableCors();
  await app.listen(process.env.PORT || 3000);
  console.log(`Backend running on http://localhost:${process.env.PORT || 3000}`);
}
bootstrap();
EOF

echo "Criando backend/src/app.module.ts"
cat > "${ROOT_DIR}/backend/src/app.module.ts" <<'EOF'
import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AuthModule } from './modules/auth/auth.module';
import { CardsModule } from './modules/cards/cards.module';
import { ReadingsModule } from './modules/readings/readings.module';
import { UsersModule } from './modules/users/users.module';
import { FavoritesModule } from './modules/favorites/favorites.module';
import { NotesModule } from './modules/notes/notes.module';
import { User } from './entities/user.entity';
import { Card } from './entities/card.entity';
import { Reading } from './entities/reading.entity';
import { Favorite } from './entities/favorite.entity';
import { Note } from './entities/note.entity';

@Module({
  imports: [
    TypeOrmModule.forRoot({
      type: 'postgres',
      host: process.env.DATABASE_HOST || 'localhost',
      port: Number(process.env.DATABASE_PORT) || 5432,
      username: process.env.DATABASE_USER || 'oraculo',
      password: process.env.DATABASE_PASSWORD || 'oraculo_password',
      database: process.env.DATABASE_NAME || 'oraculo_db',
      entities: [User, Card, Reading, Favorite, Note],
      synchronize: true
    }),
    TypeOrmModule.forFeature([User, Card, Reading, Favorite, Note]),
    AuthModule,
    CardsModule,
    ReadingsModule,
    UsersModule,
    FavoritesModule,
    NotesModule
  ],
  controllers: [],
  providers: []
})
export class AppModule {}
EOF

echo "Criando backend/entities"
cat > "${ROOT_DIR}/backend/src/entities/user.entity.ts" <<'EOF'
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
EOF

cat > "${ROOT_DIR}/backend/src/entities/card.entity.ts" <<'EOF'
import { Entity, PrimaryGeneratedColumn, Column } from 'typeorm';

@Entity()
export class Card {
  @PrimaryGeneratedColumn()
  id!: number;

  @Column()
  name!: string;

  @Column()
  arcanaType!: string; // Major | Minor

  @Column({ nullable: true })
  suit?: string; // pentacles, cups, swords, wands

  @Column({ nullable: true })
  number?: number;

  @Column({ type: 'text' })
  uprightMeaning!: string;

  @Column({ type: 'text', nullable: true })
  reversedMeaning?: string;

  @Column({ type: 'text', nullable: true })
  keywords?: string;

  @Column({ nullable: true })
  imageUrl?: string;
}
EOF

cat > "${ROOT_DIR}/backend/src/entities/reading.entity.ts" <<'EOF'
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
  @Column({ type: 'jsonb' })
  cards!: any;

  @Column({ type: 'jsonb', nullable: true })
  meta?: any;

  @Column({ type: 'boolean', default: true })
  isPrivate!: boolean;

  @CreateDateColumn()
  createdAt!: Date;
}
EOF

cat > "${ROOT_DIR}/backend/src/entities/favorite.entity.ts" <<'EOF'
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
EOF

cat > "${ROOT_DIR}/backend/src/entities/note.entity.ts" <<'EOF'
import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, CreateDateColumn } from 'typeorm';
import { User } from './user.entity';
import { Reading } from './reading.entity';

@Entity()
export class Note {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @ManyToOne(() => User, (user) => user.notes)
  user!: User;

  @ManyToOne(() => Reading)
  reading!: Reading;

  @Column({ type: 'text' })
  content!: string;

  @CreateDateColumn()
  createdAt!: Date;
}
EOF

echo "Criando modules/auth"
cat > "${ROOT_DIR}/backend/src/modules/auth/auth.module.ts" <<'EOF'
import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AuthService } from './auth.service';
import { JwtStrategy } from './jwt.strategy';
import { AuthController } from './auth.controller';
import { User } from '../../entities/user.entity';

@Module({
  imports: [
    PassportModule,
    JwtModule.register({
      secret: process.env.JWT_SECRET || 'change_this_secret',
      signOptions: { expiresIn: process.env.JWT_EXPIRATION || '3600s' }
    }),
    TypeOrmModule.forFeature([User])
  ],
  providers: [AuthService, JwtStrategy],
  controllers: [AuthController],
  exports: [AuthService]
})
export class AuthModule {}
EOF

cat > "${ROOT_DIR}/backend/src/modules/auth/auth.service.ts" <<'EOF'
import { Injectable, UnauthorizedException } from '@nestjs/common';
import { Repository } from 'typeorm';
import { InjectRepository } from '@nestjs/typeorm';
import { User } from '../../entities/user.entity';
import * as bcrypt from 'bcrypt';
import { JwtService } from '@nestjs/jwt';

@Injectable()
export class AuthService {
  constructor(
    @InjectRepository(User) private readonly usersRepo: Repository<User>,
    private readonly jwtService: JwtService
  ) {}

  async register(email: string, password: string, name?: string) {
    const exists = await this.usersRepo.findOne({ where: { email } });
    if (exists) throw new Error('User already exists');
    const hash = await bcrypt.hash(password, 10);
    const user = this.usersRepo.create({ email, passwordHash: hash, name });
    return this.usersRepo.save(user);
  }

  async validate(email: string, password: string) {
    const user = await this.usersRepo.findOne({ where: { email } });
    if (!user) throw new UnauthorizedException('Invalid credentials');
    const ok = await bcrypt.compare(password, user.passwordHash);
    if (!ok) throw new UnauthorizedException('Invalid credentials');
    return user;
  }

  async login(user: User) {
    const payload = { sub: user.id, email: user.email };
    return { accessToken: this.jwtService.sign(payload) };
  }
}
EOF

cat > "${ROOT_DIR}/backend/src/modules/auth/jwt.strategy.ts" <<'EOF'
import { Injectable } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { Strategy, ExtractJwt } from 'passport-jwt';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from '../../entities/user.entity';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(@InjectRepository(User) private readonly usersRepo: Repository<User>) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      secretOrKey: process.env.JWT_SECRET || 'change_this_secret'
    });
  }

  async validate(payload: any) {
    const user = await this.usersRepo.findOne({ where: { id: payload.sub } });
    if (!user) return null;
    return { id: user.id, email: user.email, name: user.name };
  }
}
EOF

cat > "${ROOT_DIR}/backend/src/modules/auth/auth.controller.ts" <<'EOF'
import { Controller, Post, Body, UseGuards, Request, Get } from '@nestjs/common';
import { AuthService } from './auth.service';
import { JwtAuthGuard } from './jwt-auth.guard';

@Controller('api/auth')
export class AuthController {
  constructor(private readonly auth: AuthService) {}

  @Post('register')
  async register(@Body() body: { email: string; password: string; name?: string }) {
    const user = await this.auth.register(body.email, body.password, body.name);
    return { id: user.id, email: user.email, name: user.name };
  }

  @Post('login')
  async login(@Body() body: { email: string; password: string }) {
    const user = await this.auth.validate(body.email, body.password);
    return this.auth.login(user);
  }

  @UseGuards(JwtAuthGuard)
  @Get('me')
  me(@Request() req: any) {
    return req.user;
  }
}
EOF

cat > "${ROOT_DIR}/backend/src/modules/auth/jwt-auth.guard.ts" <<'EOF'
import { Injectable } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';

@Injectable()
export class JwtAuthGuard extends AuthGuard('jwt') {}
EOF

echo "Criando modules/cards"
cat > "${ROOT_DIR}/backend/src/modules/cards/cards.module.ts" <<'EOF'
import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { CardsService } from './cards.service';
import { CardsController } from './cards.controller';
import { Card } from '../../entities/card.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Card])],
  providers: [CardsService],
  controllers: [CardsController],
  exports: [CardsService]
})
export class CardsModule {}
EOF

cat > "${ROOT_DIR}/backend/src/modules/cards/cards.service.ts" <<'EOF'
import { Injectable } from '@nestjs/common';
import { Repository, ILike } from 'typeorm';
import { InjectRepository } from '@nestjs/typeorm';
import { Card } from '../../entities/card.entity';

@Injectable()
export class CardsService {
  constructor(@InjectRepository(Card) private readonly repo: Repository<Card>) {}

  findAll(q?: string) {
    if (!q) return this.repo.find({ order: { id: 'ASC' } });
    return this.repo.find({ where: [{ name: ILike(`%${q}%`) }, { keywords: ILike(`%${q}%`) }] });
  }

  findOne(id: number) {
    return this.repo.findOne({ where: { id } });
  }

  async count() {
    return this.repo.count();
  }
}
EOF

cat > "${ROOT_DIR}/backend/src/modules/cards/cards.controller.ts" <<'EOF'
import { Controller, Get, Param, Query } from '@nestjs/common';
import { CardsService } from './cards.service';

@Controller('api/cards')
export class CardsController {
  constructor(private readonly cards: CardsService) {}

  @Get()
  list(@Query('q') q?: string) {
    return this.cards.findAll(q);
  }

  @Get(':id')
  get(@Param('id') id: string) {
    return this.cards.findOne(Number(id));
  }
}
EOF

echo "Criando modules/readings"
cat > "${ROOT_DIR}/backend/src/modules/readings/readings.module.ts" <<'EOF'
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
EOF

cat > "${ROOT_DIR}/backend/src/modules/readings/readings.service.ts" <<'EOF'
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
      cards: result,
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
EOF

cat > "${ROOT_DIR}/backend/src/modules/readings/readings.controller.ts" <<'EOF'
import { Controller, Post, Body, UseGuards, Request, Get, Query } from '@nestjs/common';
import { ReadingsService } from './readings.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

@Controller('api/readings')
export class ReadingsController {
  constructor(private readonly readingsService: ReadingsService) {}

  @UseGuards(JwtAuthGuard)
  @Post('draw')
  async draw(@Request() req: any, @Body() body: { count?: number; type?: string }) {
    const userId = req.user?.id || null;
    return this.readingsService.draw(userId, body.type || 'custom', body.count || 3);
  }

  @Get('daily')
  async daily(@Query('date') date?: string, @Query('userId') userId?: string) {
    const dateStr = date || new Date().toISOString().slice(0, 10);
    return this.readingsService.dailyCard(dateStr, userId);
  }

  @UseGuards(JwtAuthGuard)
  @Get('history')
  async history(@Request() req: any, @Query('limit') limit = 20) {
    return this.readingsService.historyForUser(req.user.id, Number(limit));
  }
}
EOF

echo "Criando seed script e cards.seed.json"
cat > "${ROOT_DIR}/backend/src/seeds/seed-cards.ts" <<'EOF'
import 'reflect-metadata';
import { DataSource } from 'typeorm';
import * as fs from 'fs';
import * as path from 'path';
import { Card } from '../entities/card.entity';
import * as dotenv from 'dotenv';
dotenv.config();

const AppDataSource = new DataSource({
  type: 'postgres',
  host: process.env.DATABASE_HOST || 'localhost',
  port: Number(process.env.DATABASE_PORT) || 5432,
  username: process.env.DATABASE_USER || 'oraculo',
  password: process.env.DATABASE_PASSWORD || 'oraculo_password',
  database: process.env.DATABASE_NAME || 'oraculo_db',
  entities: [Card],
  synchronize: true
});

async function runSeed() {
  await AppDataSource.initialize();
  const repo = AppDataSource.getRepository(Card);
  const raw = fs.readFileSync(path.join(__dirname, 'cards.seed.json'), 'utf-8');
  const cards = JSON.parse(raw);
  for (const c of cards) {
    const exists = await repo.findOne({ where: { name: c.name } });
    if (!exists) {
      const ent = repo.create(c);
      await repo.save(ent);
      console.log('Inserted', c.name);
    } else {
      console.log('Skipped', c.name);
    }
  }
  await AppDataSource.destroy();
}

runSeed().catch((e) => {
  console.error(e);
  process.exit(1);
});
EOF

cat > "${ROOT_DIR}/backend/src/seeds/cards.seed.json" <<'EOF'
[
  {"name":"O Louco","arcanaType":"Major","number":0,"uprightMeaning":"Inícios, espontaneidade, salto de fé","reversedMeaning":"Imprudência, hesitação","keywords":"início, aventura","imageUrl":"/assets/cards/0-louco.jpg"},
  {"name":"O Mago","arcanaType":"Major","number":1,"uprightMeaning":"Habilidade, concentração, ação","reversedMeaning":"Manipulação, falta de confiança","keywords":"criação, poder","imageUrl":"/assets/cards/1-mago.jpg"},
  {"name":"A Sacerdotisa","arcanaType":"Major","number":2,"uprightMeaning":"Intuição, mistério, conhecimento interior","reversedMeaning":"Segredos revelados, bloqueio intuitivo","keywords":"intuição, mistério","imageUrl":"/assets/cards/2-sacerdotisa.jpg"},
  {"name":"A Imperatriz","arcanaType":"Major","number":3,"uprightMeaning":"Abundância, nutrição, criatividade","reversedMeaning":"Dependência, estagnação","keywords":"fertilidade, beleza","imageUrl":"/assets/cards/3-imperatriz.jpg"},
  {"name":"O Imperador","arcanaType":"Major","number":4,"uprightMeaning":"Autoridade, estrutura, liderança","reversedMeaning":"Tirania, rigidez","keywords":"controle, responsabilidade","imageUrl":"/assets/cards/4-imperador.jpg"},
  {"name":"O Hierofante","arcanaType":"Major","number":5,"uprightMeaning":"Tradição, ensino, espiritualidade","reversedMeaning":"Conformismo, dogma","keywords":"sabedoria, ritual","imageUrl":"/assets/cards/5-hierofante.jpg"},
  {"name":"Os Amantes","arcanaType":"Major","number":6,"uprightMeaning":"Relacionamentos, escolhas, união","reversedMeaning":"Conflito, indecisão","keywords":"amor, parceria","imageUrl":"/assets/cards/6-amantes.jpg"},
  {"name":"O Carro","arcanaType":"Major","number":7,"uprightMeaning":"Vontade, triunfo, avanço","reversedMeaning":"Perda de controle, bloqueios","keywords":"movimento, vitória","imageUrl":"/assets/cards/7-carro.jpg"},
  {"name":"A Justiça","arcanaType":"Major","number":8,"uprightMeaning":"Equilíbrio, verdade, responsabilidade","reversedMeaning":"Injustiça, culpa","keywords":"verdade, lei","imageUrl":"/assets/cards/8-justica.jpg"},
  {"name":"O Eremita","arcanaType":"Major","number":9,"uprightMeaning":"Reflexão, busca interior, sabedoria","reversedMeaning":"Isolamento, solidão","keywords":"introspecção, guia","imageUrl":"/assets/cards/9-eremita.jpg"},
  {"name":"A Roda da Fortuna","arcanaType":"Major","number":10,"uprightMeaning":"Ciclos, sorte, mudança","reversedMeaning":"Resistência à mudança","keywords":"destino, ciclos","imageUrl":"/assets/cards/10-roda.jpg"},
  {"name":"A Força","arcanaType":"Major","number":11,"uprightMeaning":"Coragem, compaixão, controle interno","reversedMeaning":"Dúvida, fraqueza","keywords":"bravura, paciência","imageUrl":"/assets/cards/11-forca.jpg"},
  {"name":"O Enforcado","arcanaType":"Major","number":12,"uprightMeaning":"Entrega, nova perspectiva, sacrifício","reversedMeaning":"Estagnação, resistência","keywords":"rendição, pausa","imageUrl":"/assets/cards/12-enforcado.jpg"},
  {"name":"A Morte","arcanaType":"Major","number":13,"uprightMeaning":"Transformação, fim de ciclo, renascimento","reversedMeaning":"Medo da mudança","keywords":"fim, renovação","imageUrl":"/assets/cards/13-morte.jpg"},
  {"name":"A Temperança","arcanaType":"Major","number":14,"uprightMeaning":"Equilíbrio, moderação, cura","reversedMeaning":"Excessos, desarmonia","keywords":"alquimia, paciência","imageUrl":"/assets/cards/14-temperanca.jpg"},
  {"name":"O Diabo","arcanaType":"Major","number":15,"uprightMeaning":"Apegos, sombras, tentação","reversedMeaning":"Libertação, autoconsciência","keywords":"prisão, vício","imageUrl":"/assets/cards/15-diabo.jpg"},
  {"name":"A Torre","arcanaType":"Major","number":16,"uprightMeaning":"Ruína súbita, revelação, libertação","reversedMeaning":"Evitar desastre, resistência","keywords":"ruptura, verdade","imageUrl":"/assets/cards/16-torre.jpg"},
  {"name":"A Estrela","arcanaType":"Major","number":17,"uprightMeaning":"Esperança, cura, inspiração","reversedMeaning":"Desânimo, perda de fé","keywords":"cura, esperança","imageUrl":"/assets/cards/17-estrela.jpg"},
  {"name":"A Lua","arcanaType":"Major","number":18,"uprightMeaning":"Intuição, sonhos, ilusões","reversedMeaning":"Confusão, enganos","keywords":"subconsciente, mistério","imageUrl":"/assets/cards/18-lua.jpg"},
  {"name":"O Sol","arcanaType":"Major","number":19,"uprightMeaning":"Sucesso, vitalidade, alegria","reversedMeaning":"Vaidade, negatividade temporária","keywords":"clareza, sucesso","imageUrl":"/assets/cards/19-sol.jpg"},
  {"name":"O Julgamento","arcanaType":"Major","number":20,"uprightMeaning":"Avaliação, renascimento, chamado","reversedMeaning":"Autocrítica, estagnação","keywords":"renovação, avaliação","imageUrl":"/assets/cards/20-julgamento.jpg"},
  {"name":"O Mundo","arcanaType":"Major","number":21,"uprightMeaning":"Conclusão, realização, totalidade","reversedMeaning":"Falta de conclusão","keywords":"integração, sucesso","imageUrl":"/assets/cards/21-mundo.jpg"},
  {"name":"Ás de Copas","arcanaType":"Minor","suit":"cups","uprightMeaning":"Novo amor, emoção, potencial","reversedMeaning":"Bloqueio emocional","keywords":"amor, emoção","imageUrl":"/assets/cards/ace-cups.jpg"},
  {"name":"Dois de Copas","arcanaType":"Minor","suit":"cups","uprightMeaning":"Parceria, união emocional","reversedMeaning":"Desentendimento","keywords":"parceria, amor","imageUrl":"/assets/cards/2-cups.jpg"},
  {"name":"Três de Copas","arcanaType":"Minor","suit":"cups","uprightMeaning":"Celebração, amizade","reversedMeaning":"Excesso, fofoca","keywords":"festa, apoio","imageUrl":"/assets/cards/3-cups.jpg"},
  {"name":"Quatro de Copas","arcanaType":"Minor","suit":"cups","uprightMeaning":"Contemplação, tédio","reversedMeaning":"Aceitação, nova oferta","keywords":"apatia, reflexão","imageUrl":"/assets/cards/4-cups.jpg"},
  {"name":"Cinco de Copas","arcanaType":"Minor","suit":"cups","uprightMeaning":"Perda, arrependimento","reversedMeaning":"Aceitação, cura","keywords":"luto, desapontamento","imageUrl":"/assets/cards/5-cups.jpg"},
  {"name":"Seis de Copas","arcanaType":"Minor","suit":"cups","uprightMeaning":"Saudade, memórias felizes","reversedMeaning":"Viver no passado","keywords":"nostalgia, infância","imageUrl":"/assets/cards/6-cups.jpg"},
  {"name":"Sete de Copas","arcanaType":"Minor","suit":"cups","uprightMeaning":"Opções, ilusão","reversedMeaning":"Clareza, escolha","keywords":"sonhos, escolhas","imageUrl":"/assets/cards/7-cups.jpg"},
  {"name":"Oito de Copas","arcanaType":"Minor","suit":"cups","uprightMeaning":"Partida voluntária, busca interior","reversedMeaning":"Evitar mudança","keywords":"abandono, busca","imageUrl":"/assets/cards/8-cups.jpg"},
  {"name":"Nove de Copas","arcanaType":"Minor","suit":"cups","uprightMeaning":"Satisfação, desejos realizados","reversedMeaning":"Excesso, superficialidade","keywords":"desejo, contentamento","imageUrl":"/assets/cards/9-cups.jpg"},
  {"name":"Dez de Copas","arcanaType":"Minor","suit":"cups","uprightMeaning":"Felicidade familiar, harmonia","reversedMeaning":"Problemas domésticos","keywords":"lar, felicidade","imageUrl":"/assets/cards/10-cups.jpg"},
  {"name":"Pajem de Copas","arcanaType":"Minor","suit":"cups","uprightMeaning":"Mensagem emocional, sensibilidade","reversedMeaning":"Imaturidade emocional","keywords":"mensagem, sensível","imageUrl":"/assets/cards/page-cups.jpg"},
  {"name":"Cavaleiro de Copas","arcanaType":"Minor","suit":"cups","uprightMeaning":"Convite romântico, idealismo","reversedMeaning":"Desapontamento","keywords":"romântico, mensageiro","imageUrl":"/assets/cards/knight-cups.jpg"},
  {"name":"Rainha de Copas","arcanaType":"Minor","suit":"cups","uprightMeaning":"Compaixão, intuição emocional","reversedMeaning":"Excesso de sensibilidade","keywords":"empática, cuidadora","imageUrl":"/assets/cards/queen-cups.jpg"},
  {"name":"Rei de Copas","arcanaType":"Minor","suit":"cups","uprightMeaning":"Controle emocional, sabedoria","reversedMeaning":"Manipulação","keywords":"maturidade, equilíbrio","imageUrl":"/assets/cards/king-cups.jpg"},
  {"name":"Ás de Ouros","arcanaType":"Minor","suit":"pentacles","uprightMeaning":"Oportunidade material, prosperidade","reversedMeaning":"Atraso financeiro","keywords":"mão, oportunidade","imageUrl":"/assets/cards/ace-pentacles.jpg"},
  {"name":"Dois de Ouros","arcanaType":"Minor","suit":"pentacles","uprightMeaning":"Equilíbrio, gerenciamento","reversedMeaning":"Desorganização","keywords":"equilíbrio, finanças","imageUrl":"/assets/cards/2-pentacles.jpg"},
  {"name":"Três de Ouros","arcanaType":"Minor","suit":"pentacles","uprightMeaning":"Trabalho em equipe, reconhecimento","reversedMeaning":"Falta de cooperação","keywords":"colaboração, habilidade","imageUrl":"/assets/cards/3-pentacles.jpg"},
  {"name":"Quatro de Ouros","arcanaType":"Minor","suit":"pentacles","uprightMeaning":"Estabilidade, apego","reversedMeaning":"Avareza, estagnação","keywords":"economia, controle","imageUrl":"/assets/cards/4-pentacles.jpg"},
  {"name":"Cinco de Ouros","arcanaType":"Minor","suit":"pentacles","uprightMeaning":"Perda material, desafio","reversedMeaning":"Recuperação","keywords":"dificuldade, pobreza","imageUrl":"/assets/cards/5-pentacles.jpg"},
  {"name":"Seis de Ouros","arcanaType":"Minor","suit":"pentacles","uprightMeaning":"Generosidade, ajuda","reversedMeaning":"Desequilíbrio de troca","keywords":"doar, receber","imageUrl":"/assets/cards/6-pentacles.jpg"},
  {"name":"Sete de Ouros","arcanaType":"Minor","suit":"pentacles","uprightMeaning":"Avaliação, paciência","reversedMeaning":"Impaciência","keywords":"colheita, espera","imageUrl":"/assets/cards/7-pentacles.jpg"},
  {"name":"Oito de Ouros","arcanaType":"Minor","suit":"pentacles","uprightMeaning":"Aperfeiçôamento, trabalho diligente","reversedMeaning":"Perfeccionismo","keywords":"mestre, trabalho","imageUrl":"/assets/cards/8-pentacles.jpg"},
  {"name":"Nove de Ouros","arcanaType":"Minor","suit":"pentacles","uprightMeaning":"Independência material, conforto","reversedMeaning":"Solidão, vaidade","keywords":"luxo, autossuficiência","imageUrl":"/assets/cards/9-pentacles.jpg"},
  {"name":"Dez de Ouros","arcanaType":"Minor","suit":"pentacles","uprightMeaning":"Legado, família, estabilidade","reversedMeaning":"Problemas familiares","keywords":"herança, abundância","imageUrl":"/assets/cards/10-pentacles.jpg"},
  {"name":"Pajem de Ouros","arcanaType":"Minor","suit":"pentacles","uprightMeaning":"Oportunidade de aprendizado","reversedMeaning":"Desejo material sem base","keywords":"estudo, prática","imageUrl":"/assets/cards/page-pentacles.jpg"},
  {"name":"Cavaleiro de Ouros","arcanaType":"Minor","suit":"pentacles","uprightMeaning":"Trabalho consistente, confiabilidade","reversedMeaning":"Teimosia, lentidão","keywords":"prático, estável","imageUrl":"/assets/cards/knight-pentacles.jpg"},
  {"name":"Rainha de Ouros","arcanaType":"Minor","suit":"pentacles","uprightMeaning":"Nutrição material, sucesso doméstico","reversedMeaning":"Materialismo","keywords":"prática, acolhedora","imageUrl":"/assets/cards/queen-pentacles.jpg"},
  {"name":"Rei de Ouros","arcanaType":"Minor","suit":"pentacles","uprightMeaning":"Sucesso empresarial, segurança","reversedMeaning":"Ganância","keywords":"líder, prosperidade","imageUrl":"/assets/cards/king-pentacles.jpg"},
  {"name":"Ás de Espadas","arcanaType":"Minor","suit":"swords","uprightMeaning":"Clareza mental, verdade","reversedMeaning":"Confusão, bloqueio mental","keywords":"ideia, verdade","imageUrl":"/assets/cards/ace-swords.jpg"},
  {"name":"Dois de Espadas","arcanaType":"Minor","suit":"swords","uprightMeaning":"Impasse, decisão","reversedMeaning":"Desbloqueio, confusão esclarecida","keywords":"dilema, escolha","imageUrl":"/assets/cards/2-swords.jpg"},
  {"name":"Três de Espadas","arcanaType":"Minor","suit":"swords","uprightMeaning":"Coração partido, dor","reversedMeaning":"Cura, liberação da dor","keywords":"tristeza, perda","imageUrl":"/assets/cards/3-swords.jpg"},
  {"name":"Quatro de Espadas","arcanaType":"Minor","suit":"swords","uprightMeaning":"Descanso, recuperação","reversedMeaning":"Reintegração, recuperação tardia","keywords":"pausa, cura","imageUrl":"/assets/cards/4-swords.jpg"},
  {"name":"Cinco de Espadas","arcanaType":"Minor","suit":"swords","uprightMeaning":"Conflito, vitória questionável","reversedMeaning":"Arrependimento, perdão","keywords":"conflito, derrota","imageUrl":"/assets/cards/5-swords.jpg"},
  {"name":"Seis de Espadas","arcanaType":"Minor","suit":"swords","uprightMeaning":"Transição, jornada","reversedMeaning":"Resistência à mudança","keywords":"viagem, transição","imageUrl":"/assets/cards/6-swords.jpg"},
  {"name":"Sete de Espadas","arcanaType":"Minor","suit":"swords","uprightMeaning":"Estratégia, astúcia","reversedMeaning":"Verdade revelada","keywords":"furtividade, plano","imageUrl":"/assets/cards/7-swords.jpg"},
  {"name":"Oito de Espadas","arcanaType":"Minor","suit":"swords","uprightMeaning":"Sentir-se preso, restrição mental","reversedMeaning":"Libertação, clareza","keywords":"limitação, bloqueio","imageUrl":"/assets/cards/8-swords.jpg"},
  {"name":"Nove de Espadas","arcanaType":"Minor","suit":"swords","uprightMeaning":"Ansiedade, pesadelos","reversedMeaning":"Superação do medo","keywords":"preocupação, culpa","imageUrl":"/assets/cards/9-swords.jpg"},
  {"name":"Dez de Espadas","arcanaType":"Minor","suit":"swords","uprightMeaning":"Final doloroso, traição","reversedMeaning":"Recuperação, resistência","keywords":"traição, fim","imageUrl":"/assets/cards/10-swords.jpg"},
  {"name":"Pajem de Espadas","arcanaType":"Minor","suit":"swords","uprightMeaning":"Curiosidade, vigilância","reversedMeaning":"Imaturidade mental","keywords":"mensageiro, curioso","imageUrl":"/assets/cards/page-swords.jpg"},
  {"name":"Cavaleiro de Espadas","arcanaType":"Minor","suit":"swords","uprightMeaning":"Ação rápida, convicção","reversedMeaning":"Impulsividade","keywords":"rápido, confrontador","imageUrl":"/assets/cards/knight-swords.jpg"},
  {"name":"Rainha de Espadas","arcanaType":"Minor","suit":"swords","uprightMeaning":"Critério, independência","reversedMeaning":"Frieza, crueldade","keywords":"analítica, honesta","imageUrl":"/assets/cards/queen-swords.jpg"},
  {"name":"Rei de Espadas","arcanaType":"Minor","suit":"swords","uprightMeaning":"Autoridade intelectual","reversedMeaning":"Tirania intelectual","keywords":"justiça, razão","imageUrl":"/assets/cards/king-swords.jpg"},
  {"name":"Ás de Paus","arcanaType":"Minor","suit":"wands","uprightMeaning":"Inspiração, novos começos","reversedMeaning":"Bloqueio criativo","keywords":"energia, iniciativa","imageUrl":"/assets/cards/ace-wands.jpg"},
  {"name":"Dois de Paus","arcanaType":"Minor","suit":"wands","uprightMeaning":"Planejamento, decisão futura","reversedMeaning":"Medo de arriscar","keywords":"planejamento, visão","imageUrl":"/assets/cards/2-wands.jpg"},
  {"name":"Três de Paus","arcanaType":"Minor","suit":"wands","uprightMeaning":"Expansão, visão a longo prazo","reversedMeaning":"Atrasos","keywords":"progresso, internacional","imageUrl":"/assets/cards/3-wands.jpg"},
  {"name":"Quatro de Paus","arcanaType":"Minor","suit":"wands","uprightMeaning":"Celebração, estabilidade","reversedMeaning":"Tensão doméstica","keywords":"festividade, sucesso","imageUrl":"/assets/cards/4-wands.jpg"},
  {"name":"Cinco de Paus","arcanaType":"Minor","suit":"wands","uprightMeaning":"Competição, desafio","reversedMeaning":"Conflito resolvido","keywords":"luta, competição","imageUrl":"/assets/cards/5-wands.jpg"},
  {"name":"Seis de Paus","arcanaType":"Minor","suit":"wands","uprightMeaning":"Reconhecimento, vitória","reversedMeaning":"Falso triunfo","keywords":"fama, vitória","imageUrl":"/assets/cards/6-wands.jpg"},
  {"name":"Sete de Paus","arcanaType":"Minor","suit":"wands","uprightMeaning":"Defesa, manter posição","reversedMeaning":"Ceder, insegurança","keywords":"defesa, coragem","imageUrl":"/assets/cards/7-wands.jpg"},
  {"name":"Oito de Paus","arcanaType":"Minor","suit":"wands","uprightMeaning":"Movimento rápido, progresso","reversedMeaning":"Atraso, bloqueio","keywords":"velocidade, ação","imageUrl":"/assets/cards/8-wands.jpg"},
  {"name":"Nove de Paus","arcanaType":"Minor","suit":"wands","uprightMeaning":"Resiliência, persistência","reversedMeaning":"Desgaste, dúvida","keywords":"defensivo, resistência","imageUrl":"/assets/cards/9-wands.jpg"},
  {"name":"Dez de Paus","arcanaType":"Minor","suit":"wands","uprightMeaning":"Sobrecarga, responsabilidade","reversedMeaning":"Alívio, delegar","keywords":"fardo, trabalho","imageUrl":"/assets/cards/10-wands.jpg"},
  {"name":"Pajem de Paus","arcanaType":"Minor","suit":"wands","uprightMeaning":"Entusiasmo, mensageiro de boas notícias","reversedMeaning":"Imaturidade","keywords":"mensageiro, entusiasmo","imageUrl":"/assets/cards/page-wands.jpg"},
  {"name":"Cavaleiro de Paus","arcanaType":"Minor","suit":"wands","uprightMeaning":"Aventura, ousadia","reversedMeaning":"Impulsividade","keywords":"viagem, paixão","imageUrl":"/assets/cards/knight-wands.jpg"},
  {"name":"Rainha de Paus","arcanaType":"Minor","suit":"wands","uprightMeaning":"Confiança, calor humano","reversedMeaning":"Ciúme, manipulação","keywords":"vibrante, líder","imageUrl":"/assets/cards/queen-wands.jpg"},
  {"name":"Rei de Paus","arcanaType":"Minor","suit":"wands","uprightMeaning":"Visão, liderança criativa","reversedMeaning":"Tirania","keywords":"inspirador, empreendedor","imageUrl":"/assets/cards/king-wands.jpg"}
]
EOF

echo "Criando docker-compose.yml na raiz"
cat > "${ROOT_DIR}/docker-compose.yml" <<'EOF'
version: '3.8'
services:
  postgres:
    image: postgres:14
    restart: always
    environment:
      POSTGRES_DB: oraculo_db
      POSTGRES_USER: oraculo
      POSTGRES_PASSWORD: oraculo_password
    volumes:
      - oraculo-db-data:/var/lib/postgresql/data
    ports:
      - "5432:5432"

  backend:
    build:
      context: ./backend
    command: npm run start
    environment:
      PORT: 3000
      DATABASE_HOST: postgres
      DATABASE_PORT: 5432
      DATABASE_USER: oraculo
      DATABASE_PASSWORD: oraculo_password
      DATABASE_NAME: oraculo_db
      JWT_SECRET: change_this_secret
    depends_on:
      - postgres
    ports:
      - "3000:3000"
    volumes:
      - ./backend:/usr/src/app
      - /usr/src/app/node_modules

volumes:
  oraculo-db-data:
EOF

echo "Criando frontend package.json e arquivos"
cat > "${ROOT_DIR}/frontend/package.json" <<'EOF'
{
  "name": "oraculo-frontend",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "start": "ng serve --open",
    "build": "ng build"
  },
  "dependencies": {
    "@angular/animations": "~15.0.0",
    "@angular/common": "~15.0.0",
    "@angular/compiler": "~15.0.0",
    "@angular/core": "~15.0.0",
    "@angular/forms": "~15.0.0",
    "@angular/material": "^15.0.0",
    "@angular/platform-browser": "~15.0.0",
    "@angular/platform-browser-dynamic": "~15.0.0",
    "@angular/router": "~15.0.0",
    "rxjs": "~7.8.0",
    "tslib": "^2.3.0",
    "zone.js": "~0.12.0"
  },
  "devDependencies": {
    "@angular/cli": "~15.0.0",
    "typescript": "~4.9.5"
  }
}
EOF

cat > "${ROOT_DIR}/frontend/src/app/services/api.service.ts" <<'EOF'
import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { environment } from '../../environments/environment';

@Injectable({ providedIn: 'root' })
export class ApiService {
  private base = environment.apiBase;

  constructor(private http: HttpClient) {}

  private authHeaders() {
    const token = localStorage.getItem('token');
    return token ? { headers: new HttpHeaders({ Authorization: `Bearer ${token}` }) } : {};
  }

  register(payload: any) { return this.http.post(`${this.base}/api/auth/register`, payload); }
  login(payload: any) { return this.http.post(`${this.base}/api/auth/login`, payload); }
  me() { return this.http.get(`${this.base}/api/auth/me`, this.authHeaders()); }

  getCards(q?: string) {
    const qs = q ? `?q=${encodeURIComponent(q)}` : '';
    return this.http.get(`${this.base}/api/cards${qs}`);
  }

  draw(count = 3) {
    return this.http.post(`${this.base}/api/readings/draw`, { count }, this.authHeaders());
  }

  daily(date?: string) {
    const q = date ? `?date=${date}` : '';
    return this.http.get(`${this.base}/api/readings/daily${q}`);
  }

  history() { return this.http.get(`${this.base}/api/readings/history`, this.authHeaders()); }
}
EOF

cat > "${ROOT_DIR}/frontend/src/app/components/login/login.component.ts" <<'EOF'
import { Component } from '@angular/core';
import { FormBuilder, Validators } from '@angular/forms';
import { ApiService } from '../../services/api.service';
import { Router } from '@angular/router';

@Component({
  selector: 'app-login',
  template: `
  <form [formGroup]="form" (ngSubmit)="submit()">
    <input formControlName="email" placeholder="email" />
    <input formControlName="password" type="password" placeholder="senha" />
    <button type="submit">Entrar</button>
  </form>
  <button (click)="register()">Registrar</button>
  `
})
export class LoginComponent {
  form = this.fb.group({
    email: ['', [Validators.required, Validators.email]],
    password: ['', [Validators.required]]
  });

  constructor(private fb: FormBuilder, private api: ApiService, private router: Router) {}

  submit() {
    if (this.form.invalid) return;
    this.api.login(this.form.value).subscribe((res: any) => {
      localStorage.setItem('token', res.accessToken);
      this.router.navigate(['/draw']);
    });
  }

  register() {
    const payload = { email: this.form.value.email, password: this.form.value.password };
    this.api.register(payload).subscribe(() => this.submit());
  }
}
EOF

cat > "${ROOT_DIR}/frontend/src/app/components/draw/draw.component.ts" <<'EOF'
import { Component } from '@angular/core';
import { ApiService } from '../../services/api.service';

@Component({
  selector: 'app-draw',
  template: `
    <h2>Tirar cartas</h2>
    <button (click)="draw()">Tirar 3 cartas</button>
    <div *ngIf="result">
      <h3>Interpretação</h3>
      <div *ngFor="let it of result.interpretations">
        <img [src]="it.card.imageUrl" alt="{{it.card.name}}" width="80" />
        <strong>{{it.card.name}}</strong>
        <p>{{it.meaning}}</p>
      </div>
    </div>
  `
})
export class DrawComponent {
  result: any;
  constructor(private api: ApiService) {}

  draw() {
    this.api.draw(3).subscribe((r: any) => this.result = r);
  }
}
EOF

cat > "${ROOT_DIR}/frontend/src/environments/environment.ts" <<'EOF'
export const environment = {
  production: false,
  apiBase: 'http://localhost:3000'
};
EOF

echo "Criando README.md na raiz do projeto"
cat > "${ROOT_DIR}/README.md" <<'EOF'
# Oraculo

Projeto full-stack (NestJS + Angular) para site de leituras de tarot — arquitetura multicamadas e orientada a objetos.

Resumo
- Backend: NestJS, TypeORM, PostgreSQL, JWT
- Frontend: Angular, Angular Material (esqueleto)
- Seed: 78 cartas em PT-BR em backend/src/seeds/cards.seed.json
- Imagens: placeholders em /assets/cards (referenciadas nas seeds)
- Leituras privadas por padrão

Como usar (modo rápido)
1) Extraia Oraculo.zip, abra terminal na pasta Oraculo.

Backend (dev)
- cd backend
- cp .env.example .env (ajuste se necessário)
- npm install
- npm run start:dev
- Em outra janela (após garantir que o Postgres esteja rodando e configurado), rode:
  - npm run seed:cards

Frontend (dev)
- cd frontend
- npm install
- npm start
- Abra http://localhost:4200

Com Docker (dev)
- Tenha docker e docker-compose instalados.
- Na pasta Oraculo (onde docker-compose.yml está), rode:
  - docker-compose up --build
- Backend ficará em http://localhost:3000 e Postgres exposto em 5432.

Endpoints principais (exemplos)
- POST /api/auth/register { email, password, name? }
- POST /api/auth/login { email, password } -> { accessToken }
- GET /api/auth/me
- GET /api/cards
- GET /api/cards/:id
- POST /api/readings/draw { count? }
- GET /api/readings/daily
- GET /api/readings/history

Próximos passos sugeridos
- Completar UI (biblioteca completa, favoritos, notas por leitura).
- Armazenar imagens reais (S3) ou colocar arquivos locais em /frontend/src/assets/cards.
- Melhorar validações, tratar erros e adicionar testes.
- Implementar rate limit e quotas para geração de leituras.
EOF

echo "Colocando placeholders de imagem (pequenos arquivos .txt) para assets/cards"
for f in 0-louco.jpg 1-mago.jpg 2-sacerdotisa.jpg 3-imperatriz.jpg 4-imperador.jpg 5-hierofante.jpg 6-amantes.jpg 7-carro.jpg 8-justica.jpg 9-eremita.jpg 10-roda.jpg 11-forca.jpg 12-enforcado.jpg 13-morte.jpg 14-temperanca.jpg 15-diabo.jpg 16-torre.jpg 17-estrela.jpg 18-lua.jpg 19-sol.jpg 20-julgamento.jpg 21-mundo.jpg ace-cups.jpg 2-cups.jpg 3-cups.jpg 4-cups.jpg 5-cups.jpg 6-cups.jpg 7-cups.jpg 8-cups.jpg 9-cups.jpg 10-cups.jpg page-cups.jpg knight-cups.jpg queen-cups.jpg king-cups.jpg ace-pentacles.jpg 2-pentacles.jpg 3-pentacles.jpg 4-pentacles.jpg 5-pentacles.jpg 6-pentacles.jpg 7-pentacles.jpg 8-pentacles.jpg 9-pentacles.jpg 10-pentacles.jpg page-pentacles.jpg knight-pentacles.jpg queen-pentacles.jpg king-pentacles.jpg ace-swords.jpg 2-swords.jpg 3-swords.jpg 4-swords.jpg 5-swords.jpg 6-swords.jpg 7-swords.jpg 8-swords.jpg 9-swords.jpg 10-swords.jpg page-swords.jpg knight-swords.jpg queen-swords.jpg king-swords.jpg ace-wands.jpg 2-wands.jpg 3-wands.jpg 4-wands.jpg 5-wands.jpg 6-wands.jpg 7-wands.jpg 8-wands.jpg 9-wands.jpg 10-wands.jpg page-wands.jpg knight-wands.jpg queen-wands.jpg king-wands.jpg; do
  echo "placeholder for ${f}" > "${ROOT_DIR}/frontend/src/assets/cards/${f}"
done

echo "Compactando Oraculo.zip"
cd "${ROOT_DIR}/.."
zip -r "Oraculo.zip" "${ROOT_DIR}" > /dev/null
cd -

echo "Oraculo.zip criado com sucesso na pasta corrente."
ls -lh Oraculo.zip
EOF

Executando o script criará Oraculo.zip com toda a estrutura. Se quiser, eu posso:
- Ajustar o script (remover placeholders de imagens ou adicionar imagens reais),
- Incluir arquivos adicionais (ex.: README mais detalhado, GitHub Actions CI),
- Ou, se preferir, eu posso agora enviar o conteúdo do zip aqui como uma lista de arquivos (ou como arquivos individuais em blocos) para revisão antes de você executar o script.

Pronto para eu acrescentar algo mais no ZIP (ex.: CI, testes, UI final) ou quer que eu gere uma versão com imagens reais?