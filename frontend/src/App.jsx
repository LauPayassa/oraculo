import { useState, useEffect } from 'react';
import './App.css';
import { translateCardName, translateMeaning } from './translations';

function App() {
  const [cards, setCards] = useState([]);
  const [selectedCards, setSelectedCards] = useState([]);
  const [loading, setLoading] = useState(true);
  const [view, setView] = useState('gallery');
  const [spreadType, setSpreadType] = useState(1);
  const [history, setHistory] = useState([]);
  const [loadingHistory, setLoadingHistory] = useState(false);

  useEffect(() => {
    fetchCards();
  }, []);

  const fetchCards = async () => {
    try {
      const response = await fetch('http://localhost:3000/api/cards');
      const data = await response.json();
      setCards(data);
      setLoading(false);
    } catch (error) {
      console.error('Erro ao carregar cartas:', error);
      setLoading(false);
    }
  };

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

  const drawCards = async () => {
    const shuffled = [...cards].sort(() => Math.random() - 0.5);
    const drawn = shuffled.slice(0, spreadType);
    setSelectedCards(drawn);
    
    try {
      await fetch('http://localhost:3000/api/readings/save', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          type: 'custom',
          cards: drawn.map(c => ({ id: c.id, name: c.name })),
          spreadType: spreadType
        })
      });
    } catch (error) {
      console.error('Erro ao salvar leitura:', error);
    }
    
    setView('result');
  };

  const loadHistoryReading = async (readingId) => {
    try {
      const response = await fetch($"@
$"http://localhost:3000/api/readings/$+{readingId}"+);
      const data = await response.json();
      if (data && data.cards) {
        setSelectedCards(data.cards);
        setSpreadType(data.spreadType || data.cards.length);
        setView('result');
      }
    } catch (error) {
      console.error('Erro ao carregar leitura:', error);
    }
  };

  const resetReading = () => {
    setSelectedCards([]);
    setView('gallery');
  };

  const showHistory = () => {
    setView('history');
    fetchHistory();
  };

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

  if (loading) {
    return (
      <div className="loading">
        <div className="spinner"></div>
        <p>Carregando cartas do tarô...</p>
      </div>
    );
  }

  return (
    <div className="app">
      <header className="header">
        <h1> Oráculo do Tarô</h1>
        <p className="subtitle">Descubra os mistérios através das cartas</p>
      </header>

      <nav className="nav">
        <button
          className={view === 'gallery' ? 'active' : ''}
          onClick={() => setView('gallery')}
        >
           Galeria de Cartas
        </button>
        <button
          className={view === 'reading' ? 'active' : ''}
          onClick={() => setView('reading')}
        >
           Nova Leitura
        </button>
        <button
          className={view === 'history' ? 'active' : ''}
          onClick={showHistory}
        >
           Histórico
        </button>
      </nav>

      {view === 'gallery' && (
        <div className="gallery">
          <h2>Todas as Cartas ({cards.length})</h2>
          <div className="cards-grid">
            {cards.map((card) => (
              <div key={card.id} className="card-item">
                <img src={card.imageUrl} alt={translateCardName(card.name)} />
                <div className="card-info">
                  <h3>{translateCardName(card.name)}</h3>
                  <p className="card-type">
                    {card.arcanaType === 'Major' ? ' Arcano Maior' : ' Arcano Menor'}
                  </p>
                  {card.suit && (
                    <p className="card-suit">
                      {card.suit === 'cups' && ' Copas'}
                      {card.suit === 'wands' && ' Paus'}
                      {card.suit === 'swords' && ' Espadas'}
                      {card.suit === 'pentacles' && ' Ouros'}
                    </p>
                  )}
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {view === 'reading' && (
        <div className="reading-setup">
          <h2>Escolha seu Tipo de Leitura</h2>
          <div className="spread-options">
            <div
              className={spread-card $+{spreadType === 1 ? 'selected' : ''}+}
              onClick={() => setSpreadType(1)}
            >
              <h3> Uma Carta</h3>
              <p>Resposta rápida e direta</p>
              <p className="spread-desc">
                Ideal para perguntas simples do dia a dia
              </p>
            </div>
            <div
              className={spread-card $+{spreadType === 3 ? 'selected' : ''}+}
              onClick={() => setSpreadType(3)}
            >
              <h3> Três Cartas</h3>
              <p>Passado  Presente  Futuro</p>
              <p className="spread-desc">
                Visão completa da sua situação
              </p>
            </div>
            <div
              className={spread-card $+{spreadType === 5 ? 'selected' : ''}+}
              onClick={() => setSpreadType(5)}
            >
              <h3> Cruz Simples</h3>
              <p>Leitura profunda em 5 posições</p>
              <p className="spread-desc">
                Para questões complexas
              </p>
            </div>
          </div>
          <button className="draw-button" onClick={drawCards}>
             Tirar Cartas
          </button>
        </div>
      )}

      {view === 'history' && (
        <div className="history-view">
          <h2> Histórico de Leituras</h2>
          {loadingHistory ? (
            <div className="loading">
              <div className="spinner"></div>
              <p>Carregando histórico...</p>
            </div>
          ) : history.length === 0 ? (
            <div className="empty-history">
              <p> Nenhuma leitura realizada ainda</p>
              <p>Faça sua primeira leitura para começar seu histórico místico!</p>
            </div>
          ) : (
            <div className="history-grid">
              {history.map((reading) => (
                <div 
                  key={reading.id} 
                  className="history-card"
                  onClick={() => loadHistoryReading(reading.id)}
                >
                  <div className="history-header">
                    <span className="history-date"> {formatDate(reading.createdAt)}</span>
                    <span className="history-type">
                      {reading.spreadType === 1 && ' 1 Carta'}
                      {reading.spreadType === 3 && ' 3 Cartas'}
                      {reading.spreadType === 5 && ' 5 Cartas'}
                    </span>
                  </div>
                  <div className="history-cards-preview">
                    {reading.cards.slice(0, 5).map((card, idx) => (
                      <img 
                        key={idx}
                        src={card.imageUrl} 
                        alt={translateCardName(card.name)}
                        className="history-card-thumb"
                      />
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

      {view === 'result' && (
        <div className="reading-result">
          <h2> Sua Leitura</h2>
          <div className="drawn-cards">
            {selectedCards.map((card, index) => (
              <div key={card.id} className="drawn-card">
                <div className="position-label">
                  {spreadType === 3 && [' Passado', ' Presente', ' Futuro'][index]}
                  {spreadType === 5 && [' Situação Atual', ' Obstáculo', ' Objetivo', ' Base', ' Resultado'][index]}
                  {spreadType === 1 && ' Sua Carta'}
                </div>
                <img src={card.imageUrl} alt={translateCardName(card.name)} className="drawn-card-img" />
                <h3>{translateCardName(card.name)}</h3>
                <div className="card-meaning">
                  <h4> Significado Positivo:</h4>
                  <p>{translateMeaning(card.uprightMeaning)}</p>
                  <h4> Significado Invertido:</h4>
                  <p>{translateMeaning(card.reversedMeaning)}</p>
                </div>
                {card.description && (
                  <div className="card-description">
                    <h4> Descrição:</h4>
                    <p>{card.description}</p>
                  </div>
                )}
              </div>
            ))}
          </div>
          <button className="reset-button" onClick={resetReading}>
             Nova Leitura
          </button>
        </div>
      )}
    </div>
  );
}

export default App;
