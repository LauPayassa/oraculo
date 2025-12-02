import * as https from 'https';
import * as fs from 'fs';
import * as path from 'path';

interface TarotAPICard {
  name: string;
  name_short: string;
  type: string;
  suit?: string;
  value?: string;
  meaning_up: string;
  meaning_rev: string;
  desc: string;
}

interface OurCard {
  name: string;
  nameShort: string;
  arcanaType: string;
  suit?: string;
  value?: string;
  number?: number;
  uprightMeaning: string;
  reversedMeaning: string;
  description: string;
  keywords: string;
  imageUrl: string;
}

async function fetchCards(): Promise<TarotAPICard[]> {
  return new Promise((resolve, reject) => {
    https.get('https://tarotapi.dev/api/v1/cards', (res) => {
      let data = '';
      
      res.on('data', (chunk) => {
        data += chunk;
      });
      
      res.on('end', () => {
        try {
          const json = JSON.parse(data);
          resolve(json.cards || []);
        } catch (e) {
          reject(e);
        }
      });
    }).on('error', (e) => {
      reject(e);
    });
  });
}

function mapCardToOurFormat(apiCard: TarotAPICard): OurCard {
  // Traduzir tipo
  const arcanaType = apiCard.type === 'major' ? 'Major' : 'Minor';
  
  // Gerar URL da imagem Rider-Waite
  const imageUrl = `https://www.sacred-texts.com/tarot/pkt/img/${apiCard.name_short}.jpg`;
  
  // Extrair número se existir (para arcanos maiores)
  let number: number | undefined;
  if (apiCard.type === 'major') {
    const match = apiCard.value?.match(/\d+/);
    if (match) {
      number = parseInt(match[0], 10);
    }
  }
  
  // Gerar palavras-chave básicas do nome
  const keywords = apiCard.name.toLowerCase().replace(/the /gi, '').trim();
  
  return {
    name: apiCard.name,
    nameShort: apiCard.name_short,
    arcanaType,
    suit: apiCard.suit || undefined,
    value: apiCard.value || undefined,
    number,
    uprightMeaning: apiCard.meaning_up,
    reversedMeaning: apiCard.meaning_rev,
    description: apiCard.desc,
    keywords,
    imageUrl
  };
}

async function main() {
  try {
    console.log('🔮 Buscando dados da Tarot API...');
    const apiCards = await fetchCards();
    console.log(`✅ ${apiCards.length} cartas recebidas da API`);
    
    console.log('🔄 Mapeando para nosso formato...');
    const ourCards = apiCards.map(mapCardToOurFormat);
    
    const outputPath = path.join(__dirname, 'cards.json');
    fs.writeFileSync(outputPath, JSON.stringify(ourCards, null, 2), 'utf-8');
    console.log(`✅ Dados salvos em: ${outputPath}`);
    console.log(`📊 Total de cartas: ${ourCards.length}`);
    
    // Estatísticas
    const majors = ourCards.filter(c => c.arcanaType === 'Major').length;
    const minors = ourCards.filter(c => c.arcanaType === 'Minor').length;
    console.log(`   - Arcanos Maiores: ${majors}`);
    console.log(`   - Arcanos Menores: ${minors}`);
    
  } catch (error) {
    console.error('❌ Erro ao buscar dados:', error);
    process.exit(1);
  }
}

main();
