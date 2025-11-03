import React from 'react';
import './App.css';

function App() {
  return (
    <div className="App">
      <header className="App-header">
        <h1>Dockerized React App (Multi-Stage Build)</h1>
        <p>
          This React app is built with Node.js and served by Nginx using a multi-stage Docker build.
        </p>
        <a
          className="App-link"
          href="https://docs.docker.com/build/building/multi-stage/"
          target="_blank"
          rel="noopener noreferrer"
        >
          Learn about Docker multi-stage builds
        </a>
      </header>
    </div>
  );
}

export default App;
