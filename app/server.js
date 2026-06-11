const express = require('express');
const app = express();
const PORT = 3000;

app.get('/', (req, res) => {
  res.json({
    message: 'Hello from GitOps CI/CD!',
    version: process.env.VERSION || '1.0.0',
    timestamp: new Date().toISOString(),
    environment: process.env.ENV || 'development'
  });
});

app.get('/health', (req, res) => {
  res.json({ status: 'healthy', uptime: process.uptime() });
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
