# Oraculo

Projeto full-stack (NestJS + Angular) para site de leituras de tarot — arquitetura multicamadas e orientada a objetos.

Resumo
- Backend: NestJS, TypeORM, PostgreSQL, JWT
- Frontend: Angular, Angular Material (esqueleto)
- Seed: 78 cartas em PT-BR em backend/src/seeds/cards.seed.json
- Imagens: placeholders em /assets/cards (referenciadas nas seeds)
- Leituras privadas por padrão

Como usar (modo rápido)
1) Clone / extraia ZIP com as pastas `backend` e `frontend`.

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
- Na raiz (onde docker-compose.yml está), rode:
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
