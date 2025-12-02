import 'reflect-metadata';
import { DataSource } from 'typeorm';
import * as fs from 'fs';
import * as path from 'path';
import { Card } from '../entities/card.entity';
import * as dotenv from 'dotenv';
dotenv.config();

const AppDataSource = new DataSource({
  type: 'sqlite',
  database: process.env.DATABASE_PATH || 'oraculo.db',
  entities: [Card],
  synchronize: true
});

async function runSeed() {
  await AppDataSource.initialize();
  const repo = AppDataSource.getRepository(Card);
  
  // Tentar ler do novo arquivo primeiro (scripts/cards.json)
  const newPath = path.join(__dirname, '../../scripts/cards.json');
  const oldPath = path.join(__dirname, 'cards.seed.json');
  
  let cardsPath: string;
  if (fs.existsSync(newPath)) {
    cardsPath = newPath;
    console.log('📖 Usando dados da Tarot API (scripts/cards.json)');
  } else if (fs.existsSync(oldPath)) {
    cardsPath = oldPath;
    console.log('📖 Usando dados locais (cards.seed.json)');
  } else {
    console.error('❌ Nenhum arquivo de cartas encontrado!');
    console.error('Execute: npm run fetch:tarot');
    process.exit(1);
  }
  
  const raw = fs.readFileSync(cardsPath, 'utf-8');
  const cards = JSON.parse(raw);
  
  console.log(`🔮 Processando ${cards.length} cartas...`);
  let inserted = 0;
  let updated = 0;
  let skipped = 0;
  
  for (const c of cards) {
    // Tentar encontrar por nameShort primeiro, depois por name
    let exists = c.nameShort 
      ? await repo.findOne({ where: { nameShort: c.nameShort } })
      : null;
    
    if (!exists) {
      exists = await repo.findOne({ where: { name: c.name } });
    }
    
    if (!exists) {
      const ent = repo.create(c);
      await repo.save(ent);
      console.log('✅ Inserted:', c.name);
      inserted++;
    } else {
      // Atualizar campos se existir
      Object.assign(exists, c);
      await repo.save(exists);
      console.log('🔄 Updated:', c.name);
      updated++;
    }
  }
  
  console.log('\n📊 Resumo:');
  console.log(`   Inseridas: ${inserted}`);
  console.log(`   Atualizadas: ${updated}`);
  console.log(`   Total: ${cards.length}`);
  
  await AppDataSource.destroy();
}

runSeed().catch((e) => {
  console.error('❌ Erro no seed:', e);
  process.exit(1);
});