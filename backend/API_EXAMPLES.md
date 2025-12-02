# 🔮 Exemplos de Uso - API Oráculo

## 📋 Índice
- [Autenticação](#autenticação)
- [Consultar Cartas](#consultar-cartas)
- [Leituras de Tarot](#leituras-de-tarot)
- [Casos de Uso Comuns](#casos-de-uso-comuns)

## 🔐 Autenticação

### Registrar Novo Usuário
```bash
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "senha123",
    "name": "João Silva"
  }'
```

**Response:**
```json
{
  "id": 1,
  "email": "user@example.com",
  "name": "João Silva"
}
```

### Login
```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "senha123"
  }'
```

**Response:**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

## 🎴 Consultar Cartas

### 1. Listar Todas as Cartas
```bash
curl http://localhost:3000/api/cards
```

### 2. Buscar Carta por ID
```bash
curl http://localhost:3000/api/cards/1
```

**Response:**
```json
{
  "id": 1,
  "name": "The Magician",
  "nameShort": "ar01",
  "arcanaType": "Major",
  "value": "1",
  "number": 1,
  "uprightMeaning": "Skill, diplomacy, address, subtlety...",
  "reversedMeaning": "Physician, Magus, mental disease...",
  "description": "A youthful figure in the robe of a magician...",
  "keywords": "magician",
  "imageUrl": "https://www.sacred-texts.com/tarot/pkt/img/ar01.jpg"
}
```

### 3. Buscar Carta por Nome Curto (⭐ NOVO)
```bash
# The Fool (O Louco)
curl http://localhost:3000/api/cards/short/ar00

# Ace of Cups (Ás de Copas)
curl http://localhost:3000/api/cards/short/cuac

# King of Swords (Rei de Espadas)
curl http://localhost:3000/api/cards/short/swki
```

### 4. Listar Apenas Arcanos Maiores (⭐ NOVO)
```bash
curl http://localhost:3000/api/cards/majors
```

**Response:** 22 cartas dos arcanos maiores

### 5. Filtrar por Naipe (⭐ NOVO)
```bash
# Copas (Cups)
curl http://localhost:3000/api/cards?suit=cups

# Paus (Wands)
curl http://localhost:3000/api/cards?suit=wands

# Espadas (Swords)
curl http://localhost:3000/api/cards?suit=swords

# Ouros (Pentacles)
curl http://localhost:3000/api/cards?suit=pentacles
```

### 6. Busca por Texto
```bash
# Buscar por palavra-chave
curl http://localhost:3000/api/cards?q=love

# Buscar por nome
curl http://localhost:3000/api/cards?q=magician
```

### 7. Combinar Filtros
```bash
# Buscar "ace" nas cartas de copas
curl "http://localhost:3000/api/cards?q=ace&suit=cups"
```

## 🔮 Leituras de Tarot

> ⚠️ **Requer autenticação**: Use o token obtido no login

### 1. Puxar Cartas para Leitura
```bash
curl -X POST http://localhost:3000/api/readings/draw \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer SEU_TOKEN_AQUI" \
  -d '{
    "type": "custom",
    "count": 3
  }'
```

**Response:**
```json
{
  "id": 1,
  "userId": 1,
  "type": "custom",
  "cards": [
    {
      "id": 5,
      "name": "The Hierophant",
      "nameShort": "ar05",
      "arcanaType": "Major",
      "isReversed": false,
      "uprightMeaning": "Marriage, alliance, captivity...",
      "imageUrl": "https://www.sacred-texts.com/tarot/pkt/img/ar05.jpg"
    },
    {
      "id": 23,
      "name": "Ace of Wands",
      "nameShort": "waac",
      "arcanaType": "Minor",
      "suit": "wands",
      "isReversed": true,
      "reversedMeaning": "Fall, decadence, ruin...",
      "imageUrl": "https://www.sacred-texts.com/tarot/pkt/img/waac.jpg"
    },
    {
      "id": 48,
      "name": "Ten of Cups",
      "nameShort": "cu10",
      "arcanaType": "Minor",
      "suit": "cups",
      "isReversed": false,
      "uprightMeaning": "Contentment, repose of the entire heart...",
      "imageUrl": "https://www.sacred-texts.com/tarot/pkt/img/cu10.jpg"
    }
  ],
  "createdAt": "2025-12-02T10:30:00.000Z"
}
```

### 2. Carta do Dia
```bash
curl http://localhost:3000/api/readings/daily/2025-12-02 \
  -H "Authorization: Bearer SEU_TOKEN_AQUI"
```

### 3. Histórico de Leituras
```bash
# Últimas 10 leituras
curl http://localhost:3000/api/readings/history \
  -H "Authorization: Bearer SEU_TOKEN_AQUI"

# Limitar a 5 leituras
curl http://localhost:3000/api/readings/history?limit=5 \
  -H "Authorization: Bearer SEU_TOKEN_AQUI"
```

## 💡 Casos de Uso Comuns

### Caso 1: Construir Seletor de Cartas por Naipe
```javascript
// Frontend - Buscar todas as cartas de copas
async function getCardsBySuit(suit) {
  const response = await fetch(`/api/cards?suit=${suit}`);
  const cards = await response.json();
  return cards;
}

// Uso
const cupsCards = await getCardsBySuit('cups');
console.log(`${cupsCards.length} cartas de Copas`); // 14 cartas
```

### Caso 2: Exibir Apenas Arcanos Maiores
```javascript
// Frontend - Criar um carrossel com os 22 arcanos maiores
async function getMajorArcana() {
  const response = await fetch('/api/cards/majors');
  const majors = await response.json();
  return majors.sort((a, b) => a.number - b.number);
}

// Uso
const majors = await getMajorArcana();
majors.forEach(card => {
  console.log(`${card.number}: ${card.name}`);
});
```

### Caso 3: Buscar Carta Específica por Código
```javascript
// Frontend - Carregar carta específica (ex: para share link)
async function getCardByShortName(shortName) {
  try {
    const response = await fetch(`/api/cards/short/${shortName}`);
    if (!response.ok) throw new Error('Card not found');
    return await response.json();
  } catch (error) {
    console.error('Carta não encontrada:', error);
    return null;
  }
}

// Uso - Criar link compartilhável
const card = await getCardByShortName('ar01'); // The Magician
const shareUrl = `https://oraculo.app/cards/${card.nameShort}`;
```

### Caso 4: Tiragem de 3 Cartas (Passado-Presente-Futuro)
```javascript
async function doThreeCardReading(token) {
  const response = await fetch('/api/readings/draw', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${token}`
    },
    body: JSON.stringify({
      type: 'custom',
      count: 3
    })
  });
  
  const reading = await response.json();
  
  return {
    past: reading.cards[0],
    present: reading.cards[1],
    future: reading.cards[2]
  };
}

// Uso
const reading = await doThreeCardReading(userToken);
console.log('Passado:', reading.past.name);
console.log('Presente:', reading.present.name);
console.log('Futuro:', reading.future.name);
```

### Caso 5: Filtrar Cartas de Ação (Paus)
```javascript
// Frontend - Buscar cartas de ação/energia (Paus)
async function getActionCards() {
  const response = await fetch('/api/cards?suit=wands');
  return await response.json();
}

// Uso - Criar seção "Cartas de Ação"
const wandsCards = await getActionCards();
// 14 cartas: Ás até Rei de Paus
```

### Caso 6: Sistema de Busca com Autocomplete
```javascript
// Frontend - Busca com debounce
let searchTimeout;

function searchCards(query) {
  clearTimeout(searchTimeout);
  
  searchTimeout = setTimeout(async () => {
    if (query.length < 2) return;
    
    const response = await fetch(`/api/cards?q=${encodeURIComponent(query)}`);
    const results = await response.json();
    
    displaySearchResults(results);
  }, 300);
}

// Uso
searchCards('love'); // Busca cartas relacionadas a amor
```

## 📊 Referência Rápida - Códigos de Cartas

### Arcanos Maiores (ar00 - ar21)
- `ar00` - The Fool (O Louco)
- `ar01` - The Magician (O Mago)
- `ar02` - The High Priestess (A Sacerdotisa)
- ...
- `ar21` - The World (O Mundo)

### Arcanos Menores
#### Copas (Cups): `cuac`, `cu02`-`cu10`, `cupa`, `cukn`, `cuqu`, `cuki`
#### Paus (Wands): `waac`, `wa02`-`wa10`, `wapa`, `wakn`, `waqu`, `waki`
#### Espadas (Swords): `swac`, `sw02`-`sw10`, `swpa`, `swkn`, `swqu`, `swki`
#### Ouros (Pentacles): `peac`, `pe02`-`pe10`, `pepa`, `pekn`, `pequ`, `peki`

### Sufixos das Figuras
- `ac` - Ace (Ás)
- `02`-`10` - Números 2 a 10
- `pa` - Page (Pajem)
- `kn` - Knight (Cavaleiro)
- `qu` - Queen (Rainha)
- `ki` - King (Rei)

## 🔄 Fluxo Completo de Uso

```bash
# 1. Registrar usuário
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"user@test.com","password":"123456","name":"Test User"}'

# 2. Fazer login e guardar token
TOKEN=$(curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"user@test.com","password":"123456"}' \
  | jq -r '.access_token')

# 3. Explorar cartas
curl http://localhost:3000/api/cards/majors
curl http://localhost:3000/api/cards?suit=cups
curl http://localhost:3000/api/cards/short/ar01

# 4. Fazer leitura
curl -X POST http://localhost:3000/api/readings/draw \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"type":"custom","count":3}'

# 5. Ver histórico
curl http://localhost:3000/api/readings/history \
  -H "Authorization: Bearer $TOKEN"
```

## 🎯 Dicas de Performance

1. **Cache de Cartas**: As cartas raramente mudam, considere cachear a lista completa no frontend
2. **Lazy Loading de Imagens**: Carregue imagens sob demanda
3. **Pagination**: Para listagens grandes, considere adicionar paginação
4. **Filtros no Frontend**: Após carregar todas as cartas, faça filtros adicionais no cliente

## 📱 Exemplo React/Next.js

```typescript
// hooks/useCards.ts
import useSWR from 'swr';

export function useCards(suit?: string) {
  const url = suit ? `/api/cards?suit=${suit}` : '/api/cards';
  const { data, error } = useSWR(url);
  
  return {
    cards: data,
    isLoading: !error && !data,
    isError: error
  };
}

export function useMajorArcana() {
  const { data, error } = useSWR('/api/cards/majors');
  
  return {
    majors: data,
    isLoading: !error && !data,
    isError: error
  };
}

export function useCard(nameShort: string) {
  const { data, error } = useSWR(`/api/cards/short/${nameShort}`);
  
  return {
    card: data,
    isLoading: !error && !data,
    isError: error
  };
}

// Uso nos componentes
function CardList() {
  const { cards, isLoading } = useCards('cups');
  
  if (isLoading) return <Loading />;
  
  return (
    <div>
      {cards.map(card => (
        <CardItem key={card.id} card={card} />
      ))}
    </div>
  );
}
```

---

**🔮 Happy Coding!**
