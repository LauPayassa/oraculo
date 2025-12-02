import { useState, useEffect } from 'react';
import './App.css';
import { translateCardName, translateMeaning } from './translations';

function App() {
  const [cards, setCards] = useState([]);
  const [selectedCards, setSelectedCards] = useState([]);
  const [loading, setLoading] = useState(true);
  const [view, setView] = useState('gallery');
  const [spreadType, setSpreadType] = useState(1);

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

  const drawCards = () => {
    const shuffled = [...cards].sort(() => Math.random() - 0.5);
    const drawn = shuffled.slice(0, spreadType);
    setSelectedCards(drawn);
    setView('result');
  };

  const resetReading = () => {
    setSelectedCards([]);
    setView('gallery');
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
              className={`spread-card ${spreadType === 1 ? 'selected' : ''}`}
              onClick={() => setSpreadType(1)}
            >
              <h3> Uma Carta</h3>
              <p>Resposta rápida e direta</p>
              <p className="spread-desc">
                Ideal para perguntas simples do dia a dia
              </p>
            </div>
            <div 
              className={`spread-card ${spreadType === 3 ? 'selected' : ''}`}
              onClick={() => setSpreadType(3)}
            >
              <h3> Três Cartas</h3>
              <p>Passado  Presente  Futuro</p>
              <p className="spread-desc">
                Visão completa da sua situação
              </p>
            </div>
            <div 
              className={`spread-card ${spreadType === 5 ? 'selected' : ''}`}
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

      {view === 'result' && (
        <div className="reading-result">
          <h2>Sua Leitura</h2>
          <div className="drawn-cards">
            {selectedCards.map((card, index) => (
              <div key={card.id} className="drawn-card">
                <div className="position-label">
                  {spreadType === 3 && ['Passado', 'Presente', 'Futuro'][index]}
                  {spreadType === 5 && ['Situação Atual', 'Obstáculo', 'Objetivo', 'Base', 'Resultado'][index]}
                  {spreadType === 1 && 'Sua Carta'}
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
