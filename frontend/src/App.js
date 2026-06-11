import React, { useState, useEffect } from 'react';
import axios from 'axios';
import './App.css';

const API_URL = process.env.REACT_APP_API_URL || 'http://api.demo.svc.cluster.local';

function App() {
  const [apiData, setApiData] = useState(null);
  const [health, setHealth] = useState(null);
  const [callCount, setCallCount] = useState(0);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  const callAPI = async () => {
    setLoading(true);
    setError(null);
    try {
      const response = await axios.get(`${API_URL}/api`);
      setApiData(response.data);
      setCallCount(prev => prev + 1);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  const checkHealth = async () => {
    try {
      const response = await axios.get(`${API_URL}/healthz`);
      setHealth(response.data);
    } catch (err) {
      setHealth('unhealthy');
    }
  };

  useEffect(() => {
    checkHealth();
    const interval = setInterval(checkHealth, 5000);
    return () => clearInterval(interval);
  }, []);

  return (
    <div className="App">
      <header className="header">
        <div className="header-content">
          <h1>🚀 GitOps Dashboard</h1>
          <p className="subtitle">Canary Deployment Monitoring</p>
        </div>
      </header>

      <main className="main">
        <div className="dashboard">
          {/* Status Card */}
          <div className="card status-card">
            <div className="card-header">
              <h2>System Status</h2>
              <span className={`status-badge ${health === 'ok' ? 'healthy' : 'unhealthy'}`}>
                {health === 'ok' ? '✓ Healthy' : '✗ Unhealthy'}
              </span>
            </div>
            <div className="stats">
              <div className="stat">
                <span className="stat-label">API Calls</span>
                <span className="stat-value">{callCount}</span>
              </div>
              <div className="stat">
                <span className="stat-label">Version</span>
                <span className="stat-value version">{apiData?.version || 'N/A'}</span>
              </div>
            </div>
          </div>

          {/* API Response Card */}
          <div className="card response-card">
            <div className="card-header">
              <h2>API Response</h2>
            </div>
            <div className="response-content">
              {loading ? (
                <div className="loader">Loading...</div>
              ) : error ? (
                <div className="error-message">
                  <span className="error-icon">⚠️</span>
                  <p>{error}</p>
                </div>
              ) : apiData ? (
                <div className="success-message">
                  <pre>{JSON.stringify(apiData, null, 2)}</pre>
                </div>
              ) : (
                <p className="placeholder">Click "Call API" to get started</p>
              )}
            </div>
          </div>

          {/* Action Card */}
          <div className="card action-card">
            <button 
              className="action-button" 
              onClick={callAPI}
              disabled={loading}
            >
              {loading ? 'Calling...' : '📡 Call API'}
            </button>
            <button 
              className="action-button secondary" 
              onClick={checkHealth}
            >
              🏥 Check Health
            </button>
          </div>

          {/* Info Card */}
          <div className="card info-card">
            <h3>🎯 About This Dashboard</h3>
            <ul>
              <li>Frontend: React 18</li>
              <li>Backend: Flask API</li>
              <li>Deployment: Argo Rollouts (Canary)</li>
              <li>Monitoring: Prometheus + Grafana</li>
              <li>GitOps: ArgoCD</li>
            </ul>
          </div>
        </div>
      </main>

      <footer className="footer">
        <p>Built with ❤️ for GitOps Lab | Powered by Kubernetes</p>
      </footer>
    </div>
  );
}

export default App;
