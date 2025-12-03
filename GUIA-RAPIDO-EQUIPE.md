#  Oráculo - Guia Rápido para a Equipe

##  O que é o Projeto?

Aplicação full-stack de **leitura de tarot** com 78 cartas do baralho Rider-Waite. Permite visualizar todas as cartas, fazer leituras personalizadas e manter histórico completo.

---

##  Estrutura Simplificada

\\\
oraculo/
 backend/         API NestJS (Porta 3000)
    src/
       entities/       Modelos (Card, Reading, User)
       modules/        Lógica (Cards, Readings, Auth)
       seeds/          Dados iniciais (78 cartas)
    oraculo.db          Banco SQLite

 frontend/        Interface React (Porta 5173)
     src/
         App.jsx         Componente principal
         App.css         Estilos místicos
         translations.js  Traduções PT-BR
\\\

---

##  Como Rodar (2 Terminais)

### Terminal 1 - Backend
\\\ash
cd backend
npm install
npm run seed:cards    # Só na primeira vez
npm run start:dev
\\\
 Backend em http://localhost:3000

### Terminal 2 - Frontend
\\\ash
cd frontend
npm install
npm run dev
\\\
 Frontend em http://localhost:5173

---

##  Arquivos Principais

### **BACKEND**

| Arquivo | O que faz |
|---------|-----------|
| \main.ts\ | Inicia servidor na porta 3000 |
| \pp.module.ts\ | Importa módulos e configura SQLite |
| \entities/card.entity.ts\ | Define estrutura da tabela de cartas |
| \entities/reading.entity.ts\ | Define estrutura do histórico |
| \modules/cards/cards.controller.ts\ | Endpoints: \GET /api/cards\ |
| \modules/cards/cards.service.ts\ | Lógica: buscar cartas no banco |
| \modules/readings/readings.controller.ts\ | Endpoints: \POST /save\, \GET /history\ |
| \modules/readings/readings.service.ts\ | Lógica: salvar e buscar leituras |
| \seeds/cards.seed.json\ | JSON com as 78 cartas |
| \seeds/seed-cards.ts\ | Script que popula banco |

### **FRONTEND**

| Arquivo | O que faz |
|---------|-----------|
| \App.jsx\ | Componente principal com todas as views |
| \App.css\ | Todos os estilos (roxo/dourado místico) |
| \	ranslations.js\ | Traduz nomes e significados para PT-BR |
| \main.jsx\ | Entry point do React |

---

##  Endpoints da API

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| GET | \/api/cards\ | Lista todas as 78 cartas |
| GET | \/api/cards/majors\ | Apenas 22 arcanos maiores |
| GET | \/api/cards/short/:code\ | Busca carta por código (ex: ar00) |
| POST | \/api/readings/save\ | Salva uma leitura no histórico |
| GET | \/api/readings/history\ | Lista até 50 leituras recentes |
| GET | \/api/readings/:id\ | Busca leitura específica por ID |

### Exemplo de Request:
\\\javascript
// Salvar leitura
fetch('http://localhost:3000/api/readings/save', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    type: 'custom',
    cards: [{id: '1', name: 'The Fool'}],
    spreadType: 1
  })
});
\\\

---

##  Frontend - Estrutura do App.jsx

### **Estados Principais:**
\\\javascript
const [cards, setCards] = useState([]);              // 78 cartas
const [selectedCards, setSelectedCards] = useState([]);  // Leitura atual
const [view, setView] = useState('gallery');         // Navegação
const [spreadType, setSpreadType] = useState(1);     // 1, 3 ou 5
const [history, setHistory] = useState([]);          // Histórico
\\\

### **Funções Importantes:**

| Função | O que faz |
|--------|-----------|
| \etchCards()\ | Busca 78 cartas do backend |
| \drawCards()\ | Embaralha, seleciona N cartas, salva no histórico |
| \etchHistory()\ | Busca lista de leituras anteriores |
| \loadHistoryReading(id)\ | Carrega leitura antiga para revisar |
| \ormatDate()\ | Formata data em PT-BR (02/12/2024 14:30) |

### **Views (4 telas):**

1. **Gallery** (\iew === 'gallery'\)
   - Grid com todas as 78 cartas
   - Imagens + nomes traduzidos

2. **Reading** (\iew === 'reading'\)
   - Escolher tipo: 1, 3 ou 5 cartas
   - Botão "Tirar Cartas"

3. **History** (\iew === 'history'\)
   - Lista de leituras antigas
   - Miniaturas das cartas
   - Click para revisar

4. **Result** (\iew === 'result'\)
   - Cartas sorteadas
   - Significados traduzidos
   - Animações 3D

---

##  Banco de Dados (SQLite)

### **Tabelas Principais:**

**1. card** - 78 cartas do tarot
\\\
Campos: id, name, nameShort, arcanaType, suit, imageUrl, 
        uprightMeaning, reversedMeaning, description
\\\

**2. reading** - Histórico de leituras
\\\
Campos: id, userId, type, cards (JSON), meta (JSON), 
        isPrivate, createdAt
\\\

**3. user** - Usuários
\\\
Campos: id, email, password (hash), name, createdAt
\\\

---

##  Fluxos Principais

### **Fazer uma Leitura:**
1. Usuário escolhe tipo (1, 3 ou 5 cartas)
2. Clica "Tirar Cartas"
3. Frontend embaralha e seleciona aleatoriamente
4. Salva no backend (\POST /api/readings/save\)
5. Mostra resultado com animações

### **Ver Histórico:**
1. Usuário clica " Histórico"
2. Frontend busca (\GET /api/readings/history\)
3. Backend retorna leituras com cartas populadas
4. Frontend exibe grid com miniaturas

### **Revisar Leitura:**
1. Usuário clica em card do histórico
2. Frontend busca (\GET /api/readings/:id\)
3. Backend retorna leitura completa
4. Frontend exibe mesma tela de resultado

---

##  Design

### **Cores:**
- Fundo: Gradiente roxo (\#1e1e2e  #2d1b4e  #1a1a2e\)
- Destaques: Dourado (\#ffd700\)
- Secundárias: Rosa (\#ff69b4\), Ciano (\#00ffff\)

### **Animações:**
- \adeIn\ - Entrada suave de elementos
- \cardAppear\ - Flip 3D das cartas sorteadas
- \spin\ - Loading spinner
- Hover effects - Elevação e glow

### **Responsivo:**
- Desktop: Grid multi-coluna
- Mobile: 1 coluna vertical
- Breakpoint: 768px

---

##  Testar (PowerShell)

\\\powershell
# Ver todas as cartas
Invoke-RestMethod http://localhost:3000/api/cards | Select-Object -First 3

# Ver histórico
Invoke-RestMethod http://localhost:3000/api/readings/history

# Salvar leitura teste
\ = @{
  type = "custom"
  cards = @(@{id="1";name="The Fool"}, @{id="7";name="The Chariot"})
  spreadType = 3
} | ConvertTo-Json

Invoke-RestMethod -Uri http://localhost:3000/api/readings/save -Method POST -Body \ -ContentType "application/json"
\\\

---

##  Stack Tecnológica

| Camada | Tecnologia | Versão |
|--------|------------|--------|
| Backend | NestJS | 9.0.0 |
| ORM | TypeORM | 0.3.17 |
| Database | SQLite | 5.1.7 |
| Frontend | React | 19.2.0 |
| Build Tool | Vite | 7.2.4 |
| Auth | JWT | 10.0.0 |

---

##  Comandos Úteis

### Backend:
\\\ash
npm run start:dev      # Dev com hot reload
npm run build          # Build produção
npm run seed:cards     # Popular cartas
\\\

### Frontend:
\\\ash
npm run dev           # Dev server (Vite)
npm run build         # Build produção
npm run preview       # Preview do build
\\\

### Git:
\\\ash
git status
git add .
git commit -m "feat: descrição"
git push origin master:main
\\\

---

##  Troubleshooting

### Backend não inicia:
\\\ash
# Verificar se porta 3000 está ocupada
Get-Process -Name node | Stop-Process -Force

# Reinstalar dependências
rm -rf node_modules package-lock.json
npm install
\\\

### Frontend não conecta:
- Verificar se backend está rodando (http://localhost:3000/api/cards)
- Checar CORS no \main.ts\ (\pp.enableCors()\)

### Banco vazio:
\\\ash
cd backend
npm run seed:cards
\\\

---

##  Recursos Adicionais

- **Documentação completa:** \ARQUITETURA-PROJETO.md\
- **Feature histórico:** \HISTORICO-FEATURE.md\
- **GitHub:** https://github.com/LauPayassa/oraculo

---

##  Divisão de Trabalho Sugerida

### **Backend:**
- [ ] Implementar autenticação completa (login/registro)
- [ ] Adicionar endpoints de favoritos
- [ ] Implementar sistema de notas
- [ ] Criar testes unitários
- [ ] Adicionar validações com class-validator

### **Frontend:**
- [ ] Criar tela de login/registro
- [ ] Implementar sistema de favoritos
- [ ] Adicionar mais tipos de tiragem (7, 10 cartas)
- [ ] Criar tela de perfil do usuário
- [ ] Adicionar compartilhamento social

### **Design:**
- [ ] Melhorar responsividade mobile
- [ ] Criar mais animações
- [ ] Adicionar tema claro/escuro
- [ ] Implementar PWA (offline)

### **Database:**
- [ ] Criar migrations
- [ ] Adicionar índices para performance
- [ ] Implementar backup automático

---

##  Checklist de Setup

- [ ] Node.js instalado (v18+)
- [ ] Git configurado
- [ ] Clone do repositório
- [ ] \
pm install\ no backend
- [ ] \
pm install\ no frontend
- [ ] \
pm run seed:cards\ executado
- [ ] Backend rodando (porta 3000)
- [ ] Frontend rodando (porta 5173)
- [ ] Testar API com PowerShell
- [ ] Testar interface no navegador

---

##  Pronto!

Qualquer dúvida, consulte a **documentação completa** em \ARQUITETURA-PROJETO.md\ ou abra uma issue no GitHub.

**Bom trabalho, equipe!** 

