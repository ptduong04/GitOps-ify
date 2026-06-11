# GitOps Demo - Status Report

## ✅ Completed Labs

### Morning Session (Labs 0-7)
- ✅ Minikube cluster `w9` running
- ✅ ArgoCD installed and configured
- ✅ Root app-of-apps pattern implemented
- ✅ Web application (nginx) deployed with sync waves
- ✅ ArgoCD UI: https://localhost:8080 (password: `S3Xkm72ZEeG8b6o3`)

### Afternoon Session (Observability + Canary)
- ✅ Prometheus Stack installed via GitOps
- ✅ Argo Rollouts installed via GitOps
- ✅ Flask API with Prometheus metrics
- ✅ Canary deployment strategy (25%→50%→100%)
- ✅ ServiceMonitor for Prometheus scraping
- ✅ Successfully tested v1→v2 canary deployment

### Bonus Lab (Full-Stack Application)
- ✅ React frontend with modern dashboard UI
- ✅ Flask backend API with metrics
- ✅ Frontend deployed with ArgoCD
- ✅ Nginx reverse proxy configuration
- ✅ All services running and healthy

---

## 🎯 Current Deployment Status

### Backend API (Flask)
- **Status**: ✅ Running
- **Deployment Type**: Argo Rollout (Canary)
- **Pods**: 4 total (1x v2 + 3x v1)
- **Service**: ClusterIP at `api.demo.svc.cluster.local`
- **Endpoints**:
  - `/api` - Main API endpoint
  - `/healthz` - Health check
  - `/metrics` - Prometheus metrics

**Test Commands:**
```bash
kubectl exec -n demo -it POD_NAME -- python3 -c "import urllib.request; print(urllib.request.urlopen('http://localhost:5000/api').read().decode())"
```

### Frontend (React + Nginx)
- **Status**: ✅ Running
- **Deployment Type**: Standard Deployment
- **Pods**: 2 replicas
- **Service**: LoadBalancer + NodePort
- **Access URL**: http://localhost:8081 (via port-forward)

**Features:**
- Modern gradient UI with purple theme
- Real-time API status monitoring
- Health check display
- Call counter with animations
- Version display for canary testing
- Metrics viewer

**Nginx Proxy Configuration:**
- `/` → React static files
- `/api` → http://api.demo.svc.cluster.local/api
- `/healthz` → http://api.demo.svc.cluster.local/healthz
- `/metrics` → http://api.demo.svc.cluster.local/metrics

**Test Commands:**
```powershell
# Start port forward
kubectl port-forward -n demo svc/frontend 8081:80

# Test API through nginx proxy
Invoke-WebRequest -Uri http://localhost:8081/api -UseBasicParsing | Select-Object -ExpandProperty Content
Invoke-WebRequest -Uri http://localhost:8081/healthz -UseBasicParsing | Select-Object -ExpandProperty Content
```

**Expected Output:**
```json
{"message":"Hello from Flask","version":"v2"}
```

### Web Application (Nginx)
- **Status**: ✅ Running
- **Deployment Type**: Standard Deployment
- **Pods**: 5 replicas
- **Service**: ClusterIP

---

## 🔧 Critical Fix Applied

### Issue
The frontend React app was making direct HTTP calls to `http://api.demo.svc.cluster.local`, which is a Kubernetes internal DNS that browsers cannot resolve.

### Root Cause
Docker image caching - rebuilding the image didn't actually update the JavaScript bundle because Docker was reusing cached layers.

### Solution
1. Cleared Docker build cache completely
2. Deleted old Docker image from minikube
3. Rebuilt frontend image with `--no-cache` flag
4. Loaded fresh image into minikube
5. Restarted frontend pods

### Verification
```bash
# Verify NO hardcoded cluster DNS in bundle
kubectl exec -n demo deployment/frontend -- sh -c 'cat /usr/share/nginx/html/static/js/main.*.js' | Select-String 'api\.demo\.svc'
# Should return empty (no matches)

# Verify nginx proxy config
kubectl exec -n demo deployment/frontend -- cat /etc/nginx/conf.d/default.conf
```

---

## 📊 ArgoCD Applications

All applications are managed by ArgoCD in the `argocd` namespace:

1. **root** - App-of-apps (manages all other apps)
2. **web** - Nginx web application
3. **kube-prometheus-stack** - Prometheus + Grafana
4. **argo-rollouts** - Argo Rollouts operator
5. **api** - Flask API backend
6. **frontend** - React frontend

**Check Status:**
```bash
kubectl get applications -n argocd
```

---

## 🚀 Access URLs

| Service | URL | Notes |
|---------|-----|-------|
| Frontend UI | http://localhost:8081 | Run: `kubectl port-forward -n demo svc/frontend 8081:80` |
| Backend API | http://localhost:8081/api | Via frontend nginx proxy |
| ArgoCD UI | https://localhost:8080 | Password: `S3Xkm72ZEeG8b6o3` |
| Grafana | http://localhost:3000 | Via port-forward if needed |

---

## 🧪 Testing the Full Stack

### 1. Access Frontend UI
```powershell
# Start port forward (if not already running)
kubectl port-forward -n demo svc/frontend 8081:80

# Open browser
Start-Process "http://localhost:8081"
```

### 2. Test API Integration
In the frontend UI:
1. Click "📡 Call API" button
2. Should see response: `{"message":"Hello from Flask","version":"v2"}`
3. Call counter should increment
4. Health status should show "✓ Healthy"

### 3. Test Canary Deployment
```bash
# Check current rollout status
kubectl argo rollouts get rollout api -n demo

# Promote to next step (50%)
kubectl argo rollouts promote api -n demo

# Continue promoting until 100%
kubectl argo rollouts promote api -n demo
```

### 4. Monitor in Prometheus
```bash
# Port forward to Prometheus
kubectl port-forward -n monitoring svc/kube-prometheus-stack-prometheus 9090:9090

# Query: flask_api_requests_total
```

---

## 📝 Important Notes

1. **Docker Images**: All images use `imagePullPolicy: Never` (loaded locally into minikube)
2. **Minikube Profile**: Using profile `w9`
3. **Namespaces**:
   - `demo` - Application workloads
   - `argocd` - ArgoCD controller
   - `monitoring` - Prometheus stack
4. **Git Repo**: https://github.com/ptduong04/GitOps-ify.git
5. **GitOps Pattern**: All changes pushed to Git → ArgoCD auto-syncs

---

## 🐛 Troubleshooting

### Frontend not loading?
```bash
# Check pods
kubectl get pods -n demo -l app=frontend

# Check logs
kubectl logs -n demo deployment/frontend --tail=50

# Restart deployment
kubectl rollout restart deployment frontend -n demo
```

### API not responding?
```bash
# Check rollout
kubectl argo rollouts get rollout api -n demo

# Check pods
kubectl get pods -n demo -l app=api

# Test from within cluster
kubectl run test-curl --image=curlimages/curl:latest --rm -i --restart=Never -n demo -- curl -s http://api.demo.svc.cluster.local/api
```

### ArgoCD not syncing?
```bash
# Check application status
kubectl get applications -n argocd

# Force sync
kubectl patch application frontend -n argocd -p '{"operation":{"initiatedBy":{"username":"admin"},"sync":{"revision":"HEAD"}}}' --type merge
```

---

## ✅ Success Criteria

All these should work:

- ✅ Frontend UI loads at http://localhost:8081
- ✅ API calls return proper JSON responses
- ✅ Health checks show "ok" status
- ✅ Call counter increments correctly
- ✅ Version display shows current canary version
- ✅ Nginx proxy successfully forwards requests to backend
- ✅ All pods are Running (2/2 frontend, 4/4 API, 5/5 web)
- ✅ ArgoCD shows all apps as Healthy and Synced

---

🎉 **Demo is fully operational!**
