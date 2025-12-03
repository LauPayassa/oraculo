#  Oráculo - Documentação Completa da Arquitetura

##  Índice
1. [Visão Geral](#visão-geral)
2. [Estrutura do Projeto](#estrutura-do-projeto)
3. [Backend (NestJS)](#backend-nestjs)
4. [Frontend (React)](#frontend-react)
5. [Banco de Dados](#banco-de-dados)
6. [Fluxo de Dados](#fluxo-de-dados)
7. [Como Rodar](#como-rodar)

---

##  Visão Geral

**Oráculo** é uma aplicação full-stack de leitura de tarot com 78 cartas do baralho Rider-Waite. Permite aos usuários visualizar todas as cartas, fazer leituras personalizadas (1, 3 ou 5 cartas) e manter um histórico completo de todas as consultas realizadas.

### Stack Tecnológica
- **Backend:** NestJS 9.0.0 + TypeORM 0.3.17 + SQLite 5.1.7
- **Frontend:** React 19.2.0 + Vite 7.2.4
- **Banco de Dados:** SQLite (arquivo local)
- **Linguagem:** TypeScript (backend) + JavaScript (frontend)

---

##  Estrutura do Projeto

\\\
oraculo/
 backend/                    # API NestJS
    src/
       entities/          # Modelos de dados (TypeORM)
          card.entity.ts
          user.entity.ts
          reading.entity.ts
          favorite.entity.ts
          note.entity.ts
       modules/
          auth/          # Autenticação JWT
          cards/         # CRUD de cartas
          readings/      # Sistema de leituras
       seeds/             # População inicial
          cards.seed.json
          seed-cards.ts
       app.module.ts      # Módulo raiz
       main.ts            # Entry point
    oraculo.db             # Banco SQLite
    package.json
    tsconfig.json
    .env

 frontend/                   # Interface React
     src/
        App.jsx            # Componente principal
        App.css            # Estilos globais
        main.jsx           # Entry point React
        translations.js    # Traduções PT-BR
     index.html
     package.json
     vite.config.js
\\\

---

##  Backend (NestJS)

### **1. Arquivo: \main.ts\**
**Propósito:** Ponto de entrada da aplicação, configura o servidor.

\\\	ypescript
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.enableCors();  // Permite requisições do frontend
  await app.listen(3000);
  console.log(' Backend rodando em http://localhost:3000');
}
bootstrap();
\\\

**Responsabilidades:**
- Inicializa a aplicação NestJS
- Habilita CORS para comunicação com frontend
- Define porta 3000

---

### **2. Arquivo: \pp.module.ts\**
**Propósito:** Módulo raiz que importa todos os módulos da aplicação.

\\\	ypescript
@Module({
  imports: [
    TypeOrmModule.forRoot({
      type: 'sqlite',
      database: 'oraculo.db',
      entities: [Card, User, Reading, Favorite, Note],
      synchronize: true  // Cria tabelas automaticamente
    }),
    CardsModule,
    ReadingsModule,
    AuthModule
  ]
})
export class AppModule {}
\\\

**Responsabilidades:**
- Configura conexão com SQLite
- Importa módulos (Cards, Readings, Auth)
- Define entities (modelos de dados)

---

### **3. Entities (Modelos de Dados)**

#### **\card.entity.ts\** - Cartas do Tarot
\\\	ypescript
@Entity()
export class Card {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  name: string;              // Ex: "The Fool"

  @Column()
  nameShort: string;         // Ex: "ar00"

  @Column()
  arcanaType: string;        // "Major" ou "Minor"

  @Column({ nullable: true })
  suit?: string;             // "cups", "wands", "swords", "pentacles"

  @Column()
  imageUrl: string;          // URL da imagem

  @Column({ type: 'text' })
  uprightMeaning: string;    // Significado positivo

  @Column({ type: 'text' })
  reversedMeaning: string;   // Significado invertido

  @Column({ type: 'text', nullable: true })
  description?: string;      // Descrição adicional
}
\\\

**Campos principais:**
- **id:** Identificador único (UUID)
- **name:** Nome completo da carta
- **arcanaType:** Tipo de arcano (Major/Minor)
- **suit:** Naipe (apenas para arcanos menores)
- **meanings:** Significados positivo/invertido

#### **\eading.entity.ts\** - Histórico de Leituras
\\\	ypescript
@Entity()
export class Reading {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @ManyToOne(() => User, { nullable: true })
  user?: User;               // Usuário (opcional)

  @Column()
  type: string;              // "custom", "daily", etc

  @Column({ type: 'text' })
  cards: string;             // JSON: [{id, name}, ...]

  @Column({ type: 'text', nullable: true })
  meta?: string;             // JSON: {spreadType: 3}

  @Column({ type: 'boolean', default: true })
  isPrivate: boolean;

  @CreateDateColumn()
  createdAt: Date;
}
\\\

**Campos principais:**
- **cards:** Array de cartas (serializado como JSON)
- **meta:** Metadata da leitura (tipo de tiragem)
- **createdAt:** Data/hora automática

#### **\user.entity.ts\** - Usuários
\\\	ypescript
@Entity()
export class User {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ unique: true })
  email: string;

  @Column()
  password: string;          // Hash bcrypt

  @Column()
  name: string;

  @OneToMany(() => Reading, reading => reading.user)
  readings: Reading[];

  @CreateDateColumn()
  createdAt: Date;
}
\\\

#### **\avorite.entity.ts\** - Cartas Favoritas
Relaciona usuários com suas cartas favoritas.

#### **\
ote.entity.ts\** - Anotações
Permite usuários adicionar notas pessoais sobre cartas.

---

### **4. Módulo: Cards**

#### **\cards.controller.ts\** - Endpoints de Cartas
\\\	ypescript
@Controller('api/cards')
export class CardsController {
  
  @Get()
  async findAll() {
    return this.cardsService.findAll();  // Retorna todas as 78 cartas
  }

  @Get('majors')
  async findMajors() {
    return this.cardsService.findMajorArcana();  // Apenas 22 arcanos maiores
  }

  @Get('short/:code')
  async findByCode(@Param('code') code: string) {
    return this.cardsService.findByShortName(code);  // Busca por código (ex: ar00)
  }
}
\\\

**Endpoints:**
- \GET /api/cards\ - Lista todas as cartas
- \GET /api/cards/majors\ - Apenas arcanos maiores
- \GET /api/cards/short/:code\ - Busca por código

#### **\cards.service.ts\** - Lógica de Negócio
\\\	ypescript
@Injectable()
export class CardsService {
  constructor(
    @InjectRepository(Card)
    private cardRepo: Repository<Card>
  ) {}

  async findAll(): Promise<Card[]> {
    return this.cardRepo.find();
  }

  async findMajorArcana(): Promise<Card[]> {
    return this.cardRepo.find({ where: { arcanaType: 'Major' } });
  }

  async findByShortName(code: string): Promise<Card> {
    return this.cardRepo.findOne({ where: { nameShort: code } });
  }
}
\\\

**Métodos:**
- Acessa banco via Repository Pattern
- Queries otimizadas com TypeORM

---

### **5. Módulo: Readings**

#### **\eadings.controller.ts\** - Endpoints de Leituras
\\\	ypescript
@Controller('api/readings')
export class ReadingsController {

  @Post('save')
  async saveReading(@Body() body: { type, cards, spreadType }) {
    return this.readingsService.saveReading(null, body.type, body.cards, body.spreadType);
  }

  @Get('history')
  async publicHistory(@Query('limit') limit = 20) {
    return this.readingsService.getPublicHistory(Number(limit));
  }

  @Get(':id')
  async getReading(@Param('id') id: string) {
    return this.readingsService.getReadingById(id);
  }
}
\\\

**Endpoints:**
- \POST /api/readings/save\ - Salva nova leitura
- \GET /api/readings/history\ - Lista histórico (até 50)
- \GET /api/readings/:id\ - Busca leitura específica

#### **\eadings.service.ts\** - Lógica de Leituras
\\\	ypescript
async saveReading(userId, type, cards, spreadType) {
  const reading = this.readingRepo.create({
    user: userId ? { id: userId } : null,
    type: type || 'custom',
    cards: JSON.stringify(cards),  // Serializa array
    meta: JSON.stringify({ spreadType }),
    isPrivate: false
  });
  
  const saved = await this.readingRepo.save(reading);
  
  // Popular com dados completos das cartas
  const cardIds = cards.map(c => c.id);
  const fullCards = await this.cardRepo.findByIds(cardIds);
  
  return { ...saved, cardsData: fullCards };
}

async getPublicHistory(limit = 20) {
  const readings = await this.readingRepo.find({
    where: { isPrivate: false },
    order: { createdAt: 'DESC' },
    take: limit
  });

  // Enriquecer com dados das cartas
  return Promise.all(readings.map(async (reading) => {
    const cardData = JSON.parse(reading.cards);
    const cards = await this.cardRepo.findByIds(cardData.map(c => c.id));
    return {
      ...reading,
      cards,
      spreadType: JSON.parse(reading.meta || '{}').spreadType
    };
  }));
}
\\\

---

### **6. Módulo: Auth**

#### **\uth.service.ts\** - Autenticação JWT
\\\	ypescript
async validateUser(email: string, password: string) {
  const user = await this.userRepo.findOne({ where: { email } });
  if (user && await bcrypt.compare(password, user.password)) {
    return user;
  }
  return null;
}

async login(user: User) {
  const payload = { email: user.email, sub: user.id };
  return {
    access_token: this.jwtService.sign(payload)
  };
}
\\\

#### **\jwt-auth.guard.ts\** - Proteção de Rotas
\\\	ypescript
@Injectable()
export class JwtAuthGuard extends AuthGuard('jwt') {}
\\\

Usado com \@UseGuards(JwtAuthGuard)\ para proteger endpoints.

---

### **7. Seeds (População de Dados)**

#### **\cards.seed.json\** - Dados das 78 Cartas
Arquivo JSON com todas as cartas do tarot Rider-Waite:
\\\json
[
  {
    "name": "The Fool",
    "nameShort": "ar00",
    "arcanaType": "Major",
    "suit": null,
    "imageUrl": "https://tarotapi.dev/api/v1/cards/ar00.jpg",
    "uprightMeaning": "Innocence, new beginnings, free spirit",
    "reversedMeaning": "Recklessness, taken advantage of, inconsideration"
  },
  // ... 77 cartas restantes
]
\\\

#### **\seed-cards.ts\** - Script de População
\\\	ypescript
async function seedCards() {
  const dataSource = await createConnection();
  const cardRepo = dataSource.getRepository(Card);
  
  const cardsData = JSON.parse(fs.readFileSync('cards.seed.json'));
  
  for (const data of cardsData) {
    const exists = await cardRepo.findOne({ where: { nameShort: data.nameShort } });
    if (!exists) {
      await cardRepo.save(data);
    }
  }
  
  console.log(' 78 cartas populadas!');
}
\\\

**Como rodar:** \
pm run seed:cards\

---

##  Frontend (React)

### **1. Arquivo: \main.jsx\**
**Propósito:** Ponto de entrada do React.

\\\javascript
import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App';
import './App.css';

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
\\\

---

### **2. Arquivo: \App.jsx\** (Componente Principal)

#### **Estados (useState):**
\\\javascript
const [cards, setCards] = useState([]);           // 78 cartas do banco
const [selectedCards, setSelectedCards] = useState([]);  // Cartas da leitura atual
const [loading, setLoading] = useState(true);     // Loading inicial
const [view, setView] = useState('gallery');      // 'gallery', 'reading', 'history', 'result'
const [spreadType, setSpreadType] = useState(1);  // 1, 3 ou 5 cartas
const [history, setHistory] = useState([]);       // Histórico de leituras
const [loadingHistory, setLoadingHistory] = useState(false);
\\\

#### **Função: \etchCards()\** - Busca Cartas do Backend
\\\javascript
const fetchCards = async () => {
  try {
    const response = await fetch('http://localhost:3000/api/cards');
    const data = await response.json();
    setCards(data);  // Armazena 78 cartas
    setLoading(false);
  } catch (error) {
    console.error('Erro ao carregar cartas:', error);
  }
};
\\\

**Quando executa:** No \useEffect(() => { fetchCards(); }, [])\ (ao montar componente)

#### **Função: \drawCards()\** - Tira Cartas Aleatórias
\\\javascript
const drawCards = async () => {
  // 1. Embaralha e seleciona
  const shuffled = [...cards].sort(() => Math.random() - 0.5);
  const drawn = shuffled.slice(0, spreadType);
  setSelectedCards(drawn);
  
  // 2. Salva no histórico (backend)
  try {
    await fetch('http://localhost:3000/api/readings/save', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        type: 'custom',
        cards: drawn.map(c => ({ id: c.id, name: c.name })),
        spreadType: spreadType
      })
    });
  } catch (error) {
    console.error('Erro ao salvar:', error);
  }
  
  // 3. Navega para resultado
  setView('result');
};
\\\

#### **Função: \etchHistory()\** - Busca Histórico
\\\javascript
const fetchHistory = async () => {
  setLoadingHistory(true);
  try {
    const response = await fetch('http://localhost:3000/api/readings/history?limit=50');
    const data = await response.json();
    setHistory(data);
  } catch (error) {
    console.error('Erro ao carregar histórico:', error);
  }
  setLoadingHistory(false);
};
\\\

#### **Função: \loadHistoryReading(id)\** - Carrega Leitura Antiga
\\\javascript
const loadHistoryReading = async (readingId) => {
  try {
    const response = await fetch(\http://localhost:3000/api/readings/\\);
    const data = await response.json();
    
    setSelectedCards(data.cards);
    setSpreadType(data.spreadType);
    setView('result');  // Mostra resultado
  } catch (error) {
    console.error('Erro ao carregar leitura:', error);
  }
};
\\\

#### **Função: \ormatDate()\** - Formata Data em PT-BR
\\\javascript
const formatDate = (dateString) => {
  const date = new Date(dateString);
  return date.toLocaleString('pt-BR', {
    day: '2-digit',
    month: '2-digit',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  });
};
\\\
**Output:** "02/12/2024 14:30"

#### **Views (Navegação):**

**1. View: Gallery** - Galeria de Cartas
\\\javascript
{view === 'gallery' && (
  <div className="gallery">
    <h2>Todas as Cartas ({cards.length})</h2>
    <div className="cards-grid">
      {cards.map((card) => (
        <div key={card.id} className="card-item">
          <img src={card.imageUrl} alt={translateCardName(card.name)} />
          <div className="card-info">
            <h3>{translateCardName(card.name)}</h3>
            <p>{card.arcanaType === 'Major' ? ' Arcano Maior' : ' Arcano Menor'}</p>
          </div>
        </div>
      ))}
    </div>
  </div>
)}
\\\

**2. View: Reading** - Escolher Tiragem
\\\javascript
{view === 'reading' && (
  <div className="reading-setup">
    <h2>Escolha seu Tipo de Leitura</h2>
    
    {/* 3 cards para escolher: 1, 3 ou 5 cartas */}
    <div className="spread-options">
      <div onClick={() => setSpreadType(1)}> Uma Carta</div>
      <div onClick={() => setSpreadType(3)}> Três Cartas</div>
      <div onClick={() => setSpreadType(5)}> Cruz Simples</div>
    </div>
    
    <button onClick={drawCards}> Tirar Cartas</button>
  </div>
)}
\\\

**3. View: History** - Histórico de Leituras
\\\javascript
{view === 'history' && (
  <div className="history-view">
    <h2> Histórico de Leituras</h2>
    
    {history.length === 0 ? (
      <div className="empty-history">
        <p> Nenhuma leitura realizada ainda</p>
      </div>
    ) : (
      <div className="history-grid">
        {history.map((reading) => (
          <div 
            key={reading.id}
            onClick={() => loadHistoryReading(reading.id)}
            className="history-card"
          >
            <div className="history-header">
              <span> {formatDate(reading.createdAt)}</span>
              <span>{reading.spreadType} Cartas</span>
            </div>
            
            {/* Miniaturas das cartas */}
            <div className="history-cards-preview">
              {reading.cards.slice(0, 5).map((card, idx) => (
                <img key={idx} src={card.imageUrl} alt={card.name} />
              ))}
            </div>
            
            <div className="history-footer">
              <span> Clique para revisar</span>
            </div>
          </div>
        ))}
      </div>
    )}
  </div>
)}
\\\

**4. View: Result** - Resultado da Leitura
\\\javascript
{view === 'result' && (
  <div className="reading-result">
    <h2> Sua Leitura</h2>
    
    <div className="drawn-cards">
      {selectedCards.map((card, index) => (
        <div key={card.id} className="drawn-card">
          {/* Label de posição */}
          <div className="position-label">
            {spreadType === 3 && [' Passado', ' Presente', ' Futuro'][index]}
            {spreadType === 5 && [' Situação', ' Obstáculo', ' Objetivo', ' Base', ' Resultado'][index]}
            {spreadType === 1 && ' Sua Carta'}
          </div>
          
          {/* Imagem da carta */}
          <img src={card.imageUrl} alt={card.name} />
          
          {/* Nome traduzido */}
          <h3>{translateCardName(card.name)}</h3>
          
          {/* Significados */}
          <div className="card-meaning">
            <h4> Significado Positivo:</h4>
            <p>{translateMeaning(card.uprightMeaning)}</p>
            
            <h4> Significado Invertido:</h4>
            <p>{translateMeaning(card.reversedMeaning)}</p>
          </div>
        </div>
      ))}
    </div>
    
    <button onClick={resetReading}> Nova Leitura</button>
  </div>
)}
\\\

---

### **3. Arquivo: \	ranslations.js\** - Sistema de Tradução

\\\javascript
const translations = {
  // Arcanos Maiores
  'The Fool': 'O Louco',
  'The Magician': 'O Mago',
  'The High Priestess': 'A Sacerdotisa',
  'The Empress': 'A Imperatriz',
  // ... 78 cartas total
  
  // Palavras comuns
  'wisdom': 'sabedoria',
  'strength': 'força',
  'love': 'amor',
  'success': 'sucesso',
  // ... 100+ palavras
};

export const translateCardName = (name) => {
  return translations[name] || name;
};

export const translateMeaning = (meaning) => {
  let translated = meaning;
  Object.keys(translations).forEach(key => {
    const regex = new RegExp(\\\\\b\\\\\b\, 'gi');
    translated = translated.replace(regex, translations[key]);
  });
  return translated;
};
\\\

**Uso:**
- \	ranslateCardName('The Fool')\  "O Louco"
- \	ranslateMeaning('wisdom and strength')\  "sabedoria and força"

---

### **4. Arquivo: \App.css\** - Estilos Globais

#### **Paleta de Cores:**
\\\css
/* Fundo místico com gradiente */
body {
  background: linear-gradient(135deg, #1e1e2e, #2d1b4e, #1a1a2e);
}

/* Dourado para destaques */
.header h1 {
  background: linear-gradient(45deg, #ffd700, #ff69b4, #00ffff);
}
\\\

#### **Componentes Principais:**

**Cards da Galeria:**
\\\css
.card-item {
  background: rgba(255, 255, 255, 0.05);
  backdrop-filter: blur(10px);  /* Glassmorphism */
  transition: all 0.3s ease;
}

.card-item:hover {
  transform: translateY(-10px) scale(1.05);
  box-shadow: 0 15px 40px rgba(255, 215, 0, 0.4);
}
\\\

**Animações:**
\\\css
@keyframes cardAppear {
  from {
    opacity: 0;
    transform: translateY(30px) rotateY(90deg);  /* Flip 3D */
  }
  to {
    opacity: 1;
    transform: translateY(0) rotateY(0);
  }
}

.drawn-card {
  animation: cardAppear 0.6s ease backwards;
}

.drawn-card:nth-child(1) { animation-delay: 0.1s; }
.drawn-card:nth-child(2) { animation-delay: 0.2s; }
/* Delays incrementais */
\\\

**Grid Responsivo:**
\\\css
.cards-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
  gap: 25px;
}

@media (max-width: 768px) {
  .cards-grid {
    grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
  }
}
\\\

---

##  Banco de Dados

### **Arquivo: \oraculo.db\** (SQLite)

#### **Tabelas:**

**1. card** - 78 cartas do tarot
\\\sql
CREATE TABLE card (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  nameShort TEXT UNIQUE,
  arcanaType TEXT,
  suit TEXT,
  imageUrl TEXT,
  uprightMeaning TEXT,
  reversedMeaning TEXT,
  description TEXT
);
\\\

**2. reading** - Histórico de leituras
\\\sql
CREATE TABLE reading (
  id TEXT PRIMARY KEY,
  userId TEXT,
  type TEXT,
  cards TEXT,        -- JSON: [{"id":"1","name":"The Fool"}]
  meta TEXT,         -- JSON: {"spreadType":3}
  isPrivate INTEGER,
  createdAt DATETIME DEFAULT CURRENT_TIMESTAMP
);
\\\

**3. user** - Usuários
\\\sql
CREATE TABLE user (
  id TEXT PRIMARY KEY,
  email TEXT UNIQUE,
  password TEXT,     -- Hash bcrypt
  name TEXT,
  createdAt DATETIME DEFAULT CURRENT_TIMESTAMP
);
\\\

**4. favorite** - Cartas favoritas
\\\sql
CREATE TABLE favorite (
  id TEXT PRIMARY KEY,
  userId TEXT,
  cardId TEXT,
  FOREIGN KEY (userId) REFERENCES user(id),
  FOREIGN KEY (cardId) REFERENCES card(id)
);
\\\

**5. note** - Anotações
\\\sql
CREATE TABLE note (
  id TEXT PRIMARY KEY,
  userId TEXT,
  cardId TEXT,
  content TEXT,
  createdAt DATETIME,
  FOREIGN KEY (userId) REFERENCES user(id),
  FOREIGN KEY (cardId) REFERENCES card(id)
);
\\\

---

##  Fluxo de Dados

### **Fluxo: Fazer uma Leitura**

\\\
1. Usuário clica " Nova Leitura"
   
2. Frontend: setView('reading')
   
3. Usuário escolhe tipo (1, 3 ou 5 cartas)
   
4. Frontend: setSpreadType(3)
   
5. Usuário clica " Tirar Cartas"
   
6. Frontend: drawCards()
    Embaralha array de 78 cartas
    Seleciona N cartas aleatórias
    setSelectedCards(drawn)
    POST /api/readings/save
       Backend: Salva no SQLite
    setView('result')
   
7. Resultado exibido com animações
\\\

### **Fluxo: Ver Histórico**

\\\
1. Usuário clica " Histórico"
   
2. Frontend: showHistory()
    setView('history')
    fetchHistory()
       
3. GET /api/readings/history?limit=50
   
4. Backend:
    Busca leituras no SQLite
    Para cada leitura:
       Parse JSON de cards
       Busca cartas completas no banco
       Enriquece resposta
    Retorna array enriquecido
   
5. Frontend: setHistory(data)
   
6. Renderiza grid de cards com miniaturas
\\\

### **Fluxo: Revisar Leitura**

\\\
1. Usuário clica em card do histórico
   
2. Frontend: loadHistoryReading(readingId)
   
3. GET /api/readings/:id
   
4. Backend:
    Busca leitura por ID
    Parse JSON de cards
    Busca cartas completas
    Retorna leitura completa
   
5. Frontend:
    setSelectedCards(data.cards)
    setSpreadType(data.spreadType)
    setView('result')
   
6. Mesma tela de resultado é exibida
\\\

---

##  Como Rodar o Projeto

### **1. Backend (Terminal 1)**

\\\ash
cd backend
npm install                  # Instala dependências
npm run seed:cards          # Popula 78 cartas (primeira vez)
npm run start:dev           # Inicia servidor NestJS
\\\

**Servidor rodará em:** http://localhost:3000

**Endpoints disponíveis:**
- \GET /api/cards\ - 78 cartas
- \GET /api/cards/majors\ - 22 arcanos maiores
- \POST /api/readings/save\ - Salvar leitura
- \GET /api/readings/history\ - Listar histórico
- \GET /api/readings/:id\ - Buscar leitura

### **2. Frontend (Terminal 2)**

\\\ash
cd frontend
npm install                  # Instala dependências
npm run dev                 # Inicia Vite dev server
\\\

**Aplicação rodará em:** http://localhost:5173

### **3. Testar API (PowerShell)**

\\\powershell
# Listar todas as cartas
Invoke-RestMethod -Uri "http://localhost:3000/api/cards"

# Ver histórico
Invoke-RestMethod -Uri "http://localhost:3000/api/readings/history?limit=10"

# Salvar leitura manualmente
\ = @{
  type = "custom"
  cards = @(@{id="1";name="The Fool"})
  spreadType = 1
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:3000/api/readings/save" -Method POST -Body \ -ContentType "application/json"
\\\

---

##  Dependências

### **Backend (package.json)**
\\\json
{
  "dependencies": {
    "@nestjs/common": "^9.0.0",
    "@nestjs/core": "^9.0.0",
    "@nestjs/typeorm": "^9.0.1",
    "@nestjs/jwt": "^10.0.0",
    "@nestjs/passport": "^9.0.0",
    "typeorm": "^0.3.17",
    "sqlite3": "^5.1.7",
    "bcrypt": "^5.1.1",
    "passport": "^0.6.0",
    "passport-jwt": "^4.0.1"
  }
}
\\\

### **Frontend (package.json)**
\\\json
{
  "dependencies": {
    "react": "^19.2.0",
    "react-dom": "^19.2.0"
  },
  "devDependencies": {
    "@vitejs/plugin-react": "^4.2.1",
    "vite": "^7.2.4"
  }
}
\\\

---

##  Recursos Principais

###  **Implementado**
- [x] 78 cartas do Rider-Waite
- [x] Galeria completa de cartas
- [x] 3 tipos de tiragem (1, 3, 5 cartas)
- [x] Tradução completa PT-BR
- [x] Histórico de leituras
- [x] Auto-save de leituras
- [x] Preview com miniaturas
- [x] Design místico responsivo
- [x] Animações 3D
- [x] API REST completa
- [x] Banco de dados SQLite

###  **Próximas Features** (Sugestões)
- [ ] Sistema de login completo
- [ ] Histórico privado por usuário
- [ ] Cartas favoritas funcionando
- [ ] Anotações em cartas
- [ ] Mais tipos de tiragem (10 cartas, etc)
- [ ] Compartilhar leitura via link
- [ ] Exportar leitura como imagem
- [ ] PWA (funcionar offline)

---

##  Contribuindo

### **Estrutura de Commits**
\\\
feat: Nova funcionalidade
fix: Correção de bug
docs: Documentação
style: Formatação/estilo
refactor: Refatoração
test: Testes
\\\

### **Workflow de Desenvolvimento**
1. Clone o repositório
2. Crie uma branch: \git checkout -b feature/nome\
3. Faça commits: \git commit -m "feat: descrição"\
4. Push: \git push origin feature/nome\
5. Abra Pull Request

---

##  Contatos da Equipe

- **GitHub:** https://github.com/LauPayassa/oraculo
- **Frontend:** React + Vite
- **Backend:** NestJS + TypeORM
- **Database:** SQLite

---

##  Notas Técnicas

### **Por que SQLite?**
- Simplicidade (arquivo único)
- Zero configuração
- Ideal para desenvolvimento local
- Fácil de fazer backup
- Performance adequada para o projeto

### **Por que NestJS?**
- Arquitetura modular escalável
- TypeScript nativo
- Dependency Injection
- Decorators poderosos
- Comunidade ativa

### **Por que React + Vite?**
- Vite extremamente rápido
- Hot Module Replacement (HMR)
- Build otimizado
- React é padrão da indústria

---

##  Conceitos Aplicados

-  **REST API** - Endpoints padronizados
-  **ORM** - TypeORM com entities
-  **Repository Pattern** - Acesso a dados
-  **JWT Auth** - Autenticação segura
-  **CORS** - Cross-Origin Resource Sharing
-  **Hooks React** - useState, useEffect
-  **Component-Based** - Arquitetura React
-  **CSS Grid** - Layout responsivo
-  **Animations** - CSS keyframes
-  **Async/Await** - Promises modernas
-  **JSON Serialization** - Persistência
-  **Date Formatting** - Internacionalização

---

**Última atualização:** 02/12/2024  
**Versão:** 1.0.0  
**Status:**  Produção

