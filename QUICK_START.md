# GitOps Demo - Quick Start Guide

## 🚀 Start the Demo

### 1. Start Port Forward to Frontend
```powershell
kubectl port-forward -n demo svc/frontend 8081:80
```
Leave this terminal open!

### 2. Open Frontend in Browser
```powershell
Start-Process "http://localhost:8081"
```

### 3. Test the Application
Click the **"📡 Call API"** button to see:
- Backend API response with version info
- Call counter incrementing
- Health status showing "✓ Healthy"

---

## 🔍 Quick Commands

### Check All Services
```powershell
kubectl get pods -n demo
kubectl get svc -n demo
kubectl get applications -n argocd
```

### Test API Directly
```powershell
# Via frontend nginx proxy
Invoke-WebRequest -Uri http://localhost:8081/api -UseBasicParsing | Select-Object -ExpandProperty Content
Invoke-WebRequest -Uri http://localhost:8081/healthz -UseBasicParsing | Select-Object -ExpandProperty Content
```

### View Logs
```powershell
# Frontend logs
kubectl logs -n demo deployment/frontend --tail=20

# Backend API logs
kubectl logs -n demo -l app=api --tail=20
```

### ArgoCD UI
```powershell
# Access ArgoCD
Start-Process "https://localhost:8080"
# Username: admin
# Password: S3Xkm72ZEeG8b6o3
```

---

## 🎯 What You Should See

### Frontend (http://localhost:8081)
- 🚀 Modern dashboard with gradient purple theme
- 📊 System status card showing health
- 📡 API response viewer
- 🎨 Call counter with animations
- 📝 Version display (v1 or v2)

### Backend API Responses
```json
{
  "message": "Hello from Flask",
  "version": "v1"
}
```

### All Pods Running
```
NAME                        READY   STATUS
api-6dc64c744d-jpsv2        1/1     Running  (v2)
api-84b6db866d-dxvpq        1/1     Running  (v1)
api-84b6db866d-lz8wj        1/1     Running  (v1)
api-84b6db866d-sjtbz        1/1     Running  (v1)
frontend-866f8d7679-5w8jj   1/1     Running
frontend-866f8d7679-x6fwc   1/1     Running
web-6c7db45466-*            1/1     Running  (x5)
```

---

## 🔧 Canary Deployment Demo

### Check Current Rollout
```bash
kubectl argo rollouts get rollout api -n demo
```

### Promote Canary (25% → 50% → 100%)
```bash
kubectl argo rollouts promote api -n demo
```

### Watch Version Change
Refresh the frontend and keep clicking "Call API" - you'll see responses alternate between v1 and v2 based on the canary weight!

---

## 🛠️ Troubleshooting

### Frontend Not Loading?
```powershell
# Restart frontend
kubectl rollout restart deployment frontend -n demo

# Check status
kubectl get pods -n demo -l app=frontend
```

### API Not Responding?
```bash
# Check rollout status
kubectl argo rollouts get rollout api -n demo

# Test from within cluster
kubectl run test-curl --image=curlimages/curl:latest --rm -i --restart=Never -n demo -- curl -s http://api.demo.svc.cluster.local/api
```

---

## 📚 Architecture

```
┌─────────────────────────────────────────────┐
│  Browser (http://localhost:8081)           │
└─────────────────┬───────────────────────────┘
                  │
┌─────────────────▼───────────────────────────┐
│  Frontend Pod (React + Nginx)              │
│  - Serves static files                      │
│  - Proxies /api → backend                   │
└─────────────────┬───────────────────────────┘
                  │
┌─────────────────▼───────────────────────────┐
│  Backend API (Flask via Argo Rollout)      │
│  - Canary deployment (v1 + v2)             │
│  - Prometheus metrics                       │
└─────────────────────────────────────────────┘
```

---

## ✅ Success Checklist

- ✅ Port forward running on port 8081
- ✅ Frontend UI loads and looks good
- ✅ "Call API" button returns JSON response
- ✅ Health status shows green checkmark
- ✅ Call counter increments
- ✅ Version displays correctly
- ✅ No network errors in browser console

---

🎉 **Demo Ready! Enjoy!**

For full details, see [DEMO_STATUS.md](docs/DEMO_STATUS.md)
