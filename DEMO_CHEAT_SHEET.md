# 📋 DEMO CHEAT SHEET - LỆNH NHANH

> In ra và để bên cạnh khi demo!

---

## 🚀 SETUP NHANH (Chạy đầu tiên)

```powershell
# 1. Port forward frontend (Terminal 1)
kubectl port-forward -n demo svc/frontend 8081:80

# 2. Mở browser (Terminal 2)
Start-Process "http://localhost:8081"
```

---

## 🌐 DEMO FRONTEND + BACKEND

```powershell
# Test API
Invoke-WebRequest -Uri http://localhost:8081/api -UseBasicParsing | Select-Object -ExpandProperty Content

# Test Health
Invoke-WebRequest -Uri http://localhost:8081/healthz -UseBasicParsing | Select-Object -ExpandProperty Content

# Test nhiều lần (load balancing)
1..10 | ForEach-Object { (Invoke-WebRequest -Uri http://localhost:8081/api -UseBasicParsing).Content }
```

---

## 🎯 DEMO CANARY DEPLOYMENT

```bash
# Xem status
kubectl argo rollouts get rollout api -n demo

# Promote 25% → 50%
kubectl argo rollouts promote api -n demo

# Promote 50% → 100%
kubectl argo rollouts promote api -n demo

# Rollback nếu cần
kubectl argo rollouts undo api -n demo

# Xem pods
kubectl get pods -n demo -l app=api
```

---

## 📊 DEMO ARGOCD

```powershell
# Port forward ArgoCD
kubectl port-forward -n argocd svc/argocd-server 8080:443

# Mở browser
Start-Process "https://localhost:8080"

# Credentials: admin / S3Xkm72ZEeG8b6o3

# Check apps CLI
kubectl get applications -n argocd
```

---

## 📈 DEMO PROMETHEUS

```powershell
# Port forward
kubectl port-forward -n monitoring svc/kube-prometheus-stack-prometheus 9090:9090

# Mở browser
Start-Process "http://localhost:9090"

# Queries:
# - flask_api_requests_total
# - rate(flask_api_requests_total[1m])
```

---

## 🔍 KUBERNETES COMMANDS

```powershell
# Xem tất cả pods
kubectl get pods -n demo

# Xem services
kubectl get svc -n demo

# Xem logs frontend
kubectl logs -n demo deployment/frontend --tail=20

# Xem logs API
kubectl logs -n demo -l app=api --tail=20

# Describe resource
kubectl describe deployment frontend -n demo
```

---

## 🔧 TROUBLESHOOTING

```powershell
# Restart pod
kubectl rollout restart deployment frontend -n demo

# Delete pod (auto recreate)
kubectl delete pod <pod-name> -n demo

# Check pod events
kubectl describe pod <pod-name> -n demo

# Port already in use?
netstat -ano | findstr :8081
taskkill /F /PID <PID>
```

---

## 💬 KEY TALKING POINTS

### Frontend Architecture
```
Browser → Nginx Proxy → Backend API
- / → React static files
- /api → Flask API (canary)
- React 18, modern UI
```

### Canary Strategy
```
v1 (stable) ← 75% traffic
v2 (canary) ← 25% traffic
→ Promote gradually: 50% → 100%
```

### GitOps Flow
```
Code → Git Push → ArgoCD Detect → Sync → Deploy
- Git = Source of truth
- Declarative config
- Auto-sync enabled
```

---

## 📊 EXPECTED RESULTS

| Action | Expected Result |
|--------|----------------|
| Open localhost:8081 | Purple gradient dashboard |
| Click "Call API" | `{"message":"Hello from Flask","version":"v1"}` |
| Check health | Status shows "✓ Healthy" |
| Promote canary | Traffic shifts 25→50→100% |
| View ArgoCD | All apps Synced & Healthy |
| Query Prometheus | Metrics graph displayed |

---

## ⚠️ COMMON ISSUES

| Issue | Quick Fix |
|-------|-----------|
| Port forward dies | Re-run port-forward command |
| Can't reach localhost:8081 | Check port forward is running |
| Pods not Running | `kubectl get pods -n demo` |
| ArgoCD OutOfSync | Click "Sync" in UI |
| Canary stuck | `kubectl argo rollouts promote` |

---

## 🎬 DEMO FLOW (15 min)

1. **Intro** (2min) - Giải thích project
2. **Frontend** (5min) - UI + API calls
3. **Canary** (5min) - Promote v1→v2
4. **ArgoCD** (3min) - GitOps pattern
5. **Q&A** - Answer questions

---

## 📝 CREDENTIALS

- **ArgoCD**: admin / S3Xkm72ZEeG8b6o3
- **Git**: https://github.com/ptduong04/GitOps-ify.git
- **Cluster**: minikube profile `w9`

---

## ✅ PRE-DEMO CHECKLIST

```powershell
# Run health check
./pre-demo-check.ps1

# Should see:
- [x] Minikube running
- [x] All pods Running
- [x] Services exist
- [x] ArgoCD apps Synced
```

---

**🍀 GOOD LUCK!**
