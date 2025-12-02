# 🔮 Oráculo Backend

API backend para aplicação de Tarot Oráculo, desenvolvida com NestJS e TypeORM.

## 📋 Índice

- [Tecnologias](#tecnologias)
- [Integração com Tarot API](#integração-com-tarot-api)
- [Configuração](#configuração)
- [Instalação](#instalação)
- [Endpoints](#endpoints)
- [Estrutura do Projeto](#estrutura-do-projeto)
- [Créditos](#créditos)

## 🛠️ Tecnologias

- **NestJS** - Framework Node.js progressivo
- **TypeORM** - ORM para TypeScript e JavaScript
- **PostgreSQL** - Banco de dados relacional
- **TypeScript** - Superset JavaScript com tipagem estática
- **Passport JWT** - Autenticação via JSON Web Tokens

## 🎴 Integração com Tarot API

Este projeto integra dados da [Tarot API](https://github.com/ekelen/tarot-api) para fornecer informações completas sobre as 78 cartas do Tarot Rider-Waite.

### Dados Disponíveis

Cada carta contém:
- **Nome** (name): Nome da carta em português
- **Nome Curto** (nameShort): Identificador único (ex: "ar01", "swac")
- **Tipo de Arcano** (arcanaType): "Major" ou "Minor"
- **Naipe** (suit): "wands", "cups", "swords", "pentacles" (apenas arcanos menores)
- **Valor** (value): "ace", "2", "king", etc.
- **Número** (number): Posição numérica (arcanos maiores)
- **Significado Direto** (uprightMeaning): Interpretação quando a carta está na posição normal
- **Significado Invertido** (reversedMeaning): Interpretação quando a carta está invertida
- **Descrição** (description): Descrição detalhada da carta
- **Palavras-chave** (keywords): Termos associados
- **URL da Imagem** (imageUrl): Link para imagem Rider-Waite 1909

## ⚙️ Configuração

### Variáveis de Ambiente

Crie um arquivo `.env` na raiz do projeto:

```env
# Banco de Dados
DATABASE_HOST=localhost
DATABASE_PORT=5432
DATABASE_USER=oraculo
DATABASE_PASSWORD=oraculo_password
DATABASE_NAME=oraculo_db

# JWT
JWT_SECRET=sua_chave_secreta_super_segura
```

## 🚀 Instalação

### 1. Instalar Dependências

```bash
npm install
```

### 2. Buscar Dados da Tarot API

```bash
npm run fetch:tarot
```

Este comando:
- Busca todas as 78 cartas de https://tarotapi.dev/api/v1/cards
- Mapeia os dados para o formato do projeto
- Gera URLs das imagens Rider-Waite
- Salva o resultado em `scripts/cards.json`

### 3. Popular Banco de Dados

```bash
npm run seed:cards
```

Este comando:
- Lê os dados de `scripts/cards.json`
- Insere ou atualiza as cartas no banco de dados (upsert)
- Exibe estatísticas do processo

### 4. Setup Completo (Recomendado)

Para executar fetch + seed de uma vez:

```bash
npm run setup
```

### 5. Iniciar Servidor

```bash
# Modo desenvolvimento (com watch)
npm run dev

# ou
npm run start:dev

# Modo produção
npm start
```

## 📡 Endpoints

### Autenticação

#### `POST /api/auth/register`
Registrar novo usuário

**Body:**
```json
{
  "email": "user@example.com",
  "password": "senha123",
  "name": "Nome do Usuário"
}
```

#### `POST /api/auth/login`
Fazer login

**Body:**
```json
{
  "email": "user@example.com",
  "password": "senha123"
}
```

**Response:**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

### Cartas

#### `GET /api/cards`
Listar todas as cartas

**Query Params (opcionais):**
- `q`: Busca por nome ou palavras-chave
- `suit`: Filtrar por naipe ("wands", "cups", "swords", "pentacles")

**Exemplos:**
```bash
GET /api/cards
GET /api/cards?q=amor
GET /api/cards?suit=cups
```

#### `GET /api/cards/majors`
Listar apenas Arcanos Maiores (22 cartas)

#### `GET /api/cards/short/:nameShort`
Buscar carta por nome curto

**Exemplo:**
```bash
GET /api/cards/short/ar01    # Retorna "The Magician"
GET /api/cards/short/swac    # Retorna "Ace of Swords"
```

#### `GET /api/cards/:id`
Buscar carta por ID

**Exemplo:**
```bash
GET /api/cards/1
```

### Leituras (Requer autenticação)

#### `POST /api/readings/draw`
Puxar cartas para uma nova leitura

**Headers:**
```
Authorization: Bearer {access_token}
```

**Body:**
```json
{
  "type": "custom",
  "count": 3
}
```

#### `GET /api/readings/daily/:date`
Obter carta do dia

**Exemplo:**
```bash
GET /api/readings/daily/2025-12-02
```

#### `GET /api/readings/history`
Histórico de leituras do usuário

**Query Params:**
- `limit`: Quantidade de leituras (padrão: 10)

## 📁 Estrutura do Projeto

```
backend/
├── scripts/
│   ├── fetchTarotData.ts    # Script para buscar dados da Tarot API
│   └── cards.json            # Dados das cartas (gerado)
├── src/
│   ├── entities/             # Entidades TypeORM
│   │   ├── card.entity.ts
│   │   ├── user.entity.ts
│   │   ├── reading.entity.ts
│   │   ├── favorite.entity.ts
│   │   └── note.entity.ts
│   ├── modules/              # Módulos NestJS
│   │   ├── auth/            # Autenticação JWT
│   │   ├── cards/           # CRUD de cartas
│   │   ├── readings/        # Lógica de leituras
│   │   ├── users/           # Gerenciamento de usuários
│   │   ├── favorites/       # Cartas favoritas
│   │   └── notes/           # Notas em leituras
│   ├── seeds/               # Scripts de seed
│   │   ├── seed-cards.ts
│   │   └── cards.seed.json  # Backup de dados locais
│   ├── app.module.ts
│   └── main.ts
├── .env
├── package.json
├── tsconfig.json
└── README.md
```

## 🎯 Fluxo de Desenvolvimento

### Setup Inicial do Projeto
```bash
# 1. Instalar dependências
npm install

# 2. Configurar banco de dados (editar .env)

# 3. Buscar dados da Tarot API
npm run fetch:tarot

# 4. Popular banco de dados
npm run seed:cards

# 5. Iniciar servidor
npm run dev
```

### Atualizar Dados das Cartas
```bash
# Buscar novamente da API e re-popular
npm run fetch:tarot
npm run seed:cards
```

## 📚 Créditos

### Tarot API
Este projeto utiliza dados da [Tarot API](https://github.com/ekelen/tarot-api) criada por [ekelen](https://github.com/ekelen).

- **Fonte de Dados**: https://tarotapi.dev
- **Repositório**: https://github.com/ekelen/tarot-api
- **Licença**: MIT

### Rider-Waite Tarot (1909)
As imagens das cartas são provenientes do deck Rider-Waite de 1909, domínio público.

- **Fonte**: Sacred Texts Archive
- **URL Base**: https://www.sacred-texts.com/tarot/pkt/
- **Ilustradora**: Pamela Colman Smith
- **Designer**: Arthur Edward Waite

## 📄 Licença

Este projeto está sob a licença MIT.

## 🤝 Contribuindo

1. Faça um fork do projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📞 Suporte

Para questões e suporte, abra uma issue no repositório do projeto.
