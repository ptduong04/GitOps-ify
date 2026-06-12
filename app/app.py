import os, random
from flask import Flask
from prometheus_client import Counter, Histogram, generate_latest

app = Flask(__name__)

REQUEST_COUNT = Counter(
    'flask_http_request_total',
    'Total HTTP requests',
    ['method', 'endpoint', 'status', 'version']
)
REQUEST_LATENCY = Histogram('flask_http_request_duration_seconds', 'HTTP request latency')

@app.route('/healthz')
def health():
    return 'ok', 200

@app.route('/api')
@REQUEST_LATENCY.time()
def api():
    version = os.getenv('VERSION', 'v1')
    error_rate = float(os.getenv('INJECT_ERROR_RATE', '0'))
    if random.random() < error_rate:
        REQUEST_COUNT.labels(method='GET', endpoint='/api', status='500', version=version).inc()
        return {'error': 'random failure', 'version': version}, 500
    REQUEST_COUNT.labels(method='GET', endpoint='/api', status='200', version=version).inc()
    return {'message': 'Hello from Flask', 'version': version}, 200

@app.route('/metrics')
def metrics():
    return generate_latest(), 200, {'Content-Type': 'text/plain; charset=utf-8'}

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
