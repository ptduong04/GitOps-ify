# 🎯 HƯỚNG DẪN DEMO CHO MENTOR

## 📋 CHUẨN BỊ TRƯỚC KHI DEMO

### 1. Kiểm Tra Minikube Đang Chạy
```powershell
# Kiểm tra status
minikube -p w9 status

# Nếu chưa chạy, start lại
minikube -p w9 start
```

### 2. Kiểm Tra Tất Cả Pods
```powershell
# Xem tất cả pods trong namespace demo
kubectl get pods -n demo

# Kết quả mong đợi: Tất cả pods phải ở trạng thái Running
# - frontend: 2 pods
# - api: 4 pods (canary deployment)
# - web: 5 pods
```

### 3. Kiểm Tra ArgoCD Applications
```powershell
# Xem tất cả applications
kubectl get applications -n argocd

# Kết quả mong đợi:
# - root: Synced, Healthy
# - web: Synced, Healthy
# - frontend: Synced
# - api: Synced
# - argo-rollouts: Healthy
```

---

## 🚀 DEMO 1: FULL-STACK APPLICATION (Frontend + Backend)

### Bước 1: Start Port Forward
```powershell
# Mở terminal 1 - Port forward frontend
kubectl port-forward -n demo svc/frontend 8081:80
```
**⚠️ Chú ý**: Để terminal này mở, KHÔNG đóng!

### Bước 2: Mở Frontend UI
```powershell
# Mở terminal 2 - Launch browser
Start-Process "http://localhost:8081"
```

### Bước 3: Demo Các Tính Năng Frontend

**Trong browser, mentor sẽ thấy:**
- ✅ Dashboard với UI gradient màu tím đẹp mắt
- ✅ System Status Card hiển thị health status
- ✅ Call counter (số lần gọi API)
- ✅ Version display (v1 hoặc v2)

**Thao tác demo:**
1. Click nút **"📡 Call API"**
2. Xem response hiển thị: `{"message":"Hello from Flask","version":"v1"}`
3. Call counter tăng lên
4. Click nút **"🏥 Check Health"**
5. Health status hiển thị: **"✓ Healthy"**

### Bước 4: Test API Bằng Command Line
```powershell
# Terminal 3 - Test API endpoint
Invoke-WebRequest -Uri http://localhost:8081/api -UseBasicParsing | Select-Object -ExpandProperty Content

# Kết quả: {"message":"Hello from Flask","version":"v1"}

# Test health endpoint
Invoke-WebRequest -Uri http://localhost:8081/healthz -UseBasicParsing | Select-Object -ExpandProperty Content

# Kết quả: ok
```

### Bước 5: Giải Thích Kiến Trúc
```
📱 Browser (localhost:8081)
    ↓
🌐 Nginx Reverse Proxy (trong Frontend Pod)
    ├─ / → React Static Files
    ├─ /api → Proxy to Backend
    ├─ /healthz → Proxy to Backend
    └─ /metrics → Proxy to Backend
    ↓
🐍 Flask API (Backend Pod - Canary Deployment)
    ├─ 25% traffic → v2 (1 pod)
    └─ 75% traffic → v1 (3 pods)
```

**Giải thích cho mentor:**
- Frontend sử dụng React 18
- Nginx làm reverse proxy để frontend gọi API
- Backend là Flask API với Prometheus metrics
- Tất cả deploy qua GitOps với ArgoCD

---

## 🎯 DEMO 2: CANARY DEPLOYMENT VỚI ARGO ROLLOUTS

### Bước 1: Xem Trạng Thái Canary Hiện Tại
```bash
# Xem rollout status
kubectl argo rollouts get rollout api -n demo
```

**Giải thích kết quả cho mentor:**
- Hiện tại: 25% traffic đang ở v2, 75% ở v1
- 1 pod v2 (new version)
- 3 pods v1 (stable version)
- Status: Paused (đang chờ promote)

### Bước 2: Promote Canary Lên 50%
```bash
# Promote từ 25% → 50%
kubectl argo rollouts promote api -n demo

# Xem lại status
kubectl argo rollouts get rollout api -n demo
```

**Giải thích cho mentor:**
- Traffic bây giờ: 50% v2, 50% v1
- 2 pods v2, 2 pods v1
- Canary deployment đang tiến triển

### Bước 3: Test Load Balancing
```powershell
# Gọi API nhiều lần để thấy load balancing
for ($i=1; $i -le 10; $i++) {
    $response = Invoke-WebRequest -Uri http://localhost:8081/api -UseBasicParsing | Select-Object -ExpandProperty Content
    Write-Host "Request $i : $response"
    Start-Sleep -Milliseconds 500
}
```

**Giải thích cho mentor:**
- Sẽ thấy response xen kẽ giữa v1 và v2
- Tỷ lệ 50:50 nếu đã promote
- Đây là canary testing trong thực tế

### Bước 4: Promote Lên 100% (Full Rollout)
```bash
# Promote lên 100% v2
kubectl argo rollouts promote api -n demo

# Xem kết quả cuối cùng
kubectl argo rollouts get rollout api -n demo

# Xem tất cả pods
kubectl get pods -n demo -l app=api
```

**Giải thích cho mentor:**
- Bây giờ 100% traffic đi vào v2
- Tất cả 4 pods đều chạy v2
- Deployment hoàn tất thành công
- Có thể rollback nếu có vấn đề

### Bước 5: Rollback Nếu Cần (Optional Demo)
```bash
# Rollback về version trước
kubectl argo rollouts undo api -n demo

# Xem status
kubectl argo rollouts get rollout api -n demo
```

---

## 📊 DEMO 3: GITOPS VỚI ARGOCD

### Bước 1: Mở ArgoCD UI
```powershell
# Port forward ArgoCD (nếu chưa có)
kubectl port-forward -n argocd svc/argocd-server 8080:443

# Mở browser
Start-Process "https://localhost:8080"
```

**Credentials:**
- Username: `admin`
- Password: `S3Xkm72ZEeG8b6o3`

### Bước 2: Giải Thích App-of-Apps Pattern

**Trong ArgoCD UI, chỉ cho mentor thấy:**

1. **Root Application**
   - Click vào `root` app
   - Giải thích: Đây là app-of-apps, quản lý tất cả child apps

2. **Child Applications**
   - `web` - Nginx web application
   - `frontend` - React frontend
   - `api` - Flask API backend
   - `kube-prometheus-stack` - Prometheus + Grafana
   - `argo-rollouts` - Argo Rollouts operator

3. **Sync Status**
   - Màu xanh = Synced (Git và cluster giống nhau)
   - Health Status = Healthy

### Bước 3: Demo GitOps Workflow

**Giải thích quy trình cho mentor:**
```
1. Developer thay đổi code
   ↓
2. Commit và push lên GitHub
   ↓
3. ArgoCD tự động detect thay đổi
   ↓
4. ArgoCD sync và deploy vào cluster
   ↓
5. Application tự động update
```

### Bước 4: Xem Application Details
```powershell
# Xem chi tiết app frontend
kubectl get application frontend -n argocd -o yaml

# Xem history
kubectl get application frontend -n argocd -o jsonpath='{.status.history}'
```

**Giải thích cho mentor:**
- Git repo: https://github.com/ptduong04/GitOps-ify.git
- Path: k8s-frontend/
- Auto-sync: enabled
- Self-heal: enabled (tự động fix nếu ai đó modify trực tiếp)

---

## 🔍 DEMO 4: MONITORING VỚI PROMETHEUS

### Bước 1: Port Forward Prometheus
```powershell
# Port forward Prometheus UI
kubectl port-forward -n monitoring svc/kube-prometheus-stack-prometheus 9090:9090

# Mở browser
Start-Process "http://localhost:9090"
```

### Bước 2: Query Metrics

**Trong Prometheus UI, chạy các query:**

1. **Total API Requests**
   ```promql
   flask_api_requests_total
   ```

2. **Request Rate (requests per second)**
   ```promql
   rate(flask_api_requests_total[1m])
   ```

3. **API Response Time**
   ```promql
   flask_api_response_time_seconds
   ```

**Giải thích cho mentor:**
- Flask API đang expose metrics ở `/metrics` endpoint
- ServiceMonitor tự động scrape metrics
- Prometheus lưu trữ và query metrics

### Bước 3: Test Metrics Endpoint
```powershell
# Xem raw metrics
Invoke-WebRequest -Uri http://localhost:8081/metrics -UseBasicParsing | Select-Object -ExpandProperty Content
```

---

## 📦 DEMO 5: KUBERNETES RESOURCES

### Xem Tất Cả Resources
```powershell
# Pods trong namespace demo
kubectl get pods -n demo -o wide

# Services
kubectl get svc -n demo

# Rollouts (Argo Rollouts CRD)
kubectl get rollouts -n demo

# Deployments
kubectl get deployments -n demo
```

### Xem Logs Real-time
```powershell
# Frontend logs
kubectl logs -n demo deployment/frontend --tail=20 -f

# Backend logs (từ một pod cụ thể)
kubectl logs -n demo -l app=api --tail=20 --max-log-requests=4
```

### Describe Resources
```powershell
# Xem chi tiết frontend deployment
kubectl describe deployment frontend -n demo

# Xem chi tiết api rollout
kubectl describe rollout api -n demo

# Xem service frontend
kubectl describe svc frontend -n demo
```

---

## 🎬 KỊCH BẢN DEMO ĐẦY ĐỦ (15-20 PHÚT)

### Phần 1: Giới Thiệu (2 phút)
```
"Em đã làm một demo về GitOps với ArgoCD, bao gồm:
- Full-stack application (React frontend + Flask backend)
- Canary deployment với Argo Rollouts
- Monitoring với Prometheus
- Tất cả deploy qua GitOps pattern"
```

### Phần 2: Demo Frontend + Backend (5 phút)
1. Start port forward → Mở browser
2. Click "Call API" → Xem response
3. Giải thích kiến trúc Nginx proxy
4. Test bằng command line

### Phần 3: Demo Canary Deployment (5 phút)
1. Xem status hiện tại (25% v2)
2. Promote lên 50%
3. Test load balancing
4. Promote lên 100%
5. Giải thích lợi ích của canary

### Phần 4: Demo GitOps với ArgoCD (5 phút)
1. Mở ArgoCD UI
2. Giải thích app-of-apps pattern
3. Xem sync status
4. Giải thích GitOps workflow

### Phần 5: Demo Monitoring (3 phút)
1. Mở Prometheus
2. Query metrics
3. Xem metrics endpoint

### Phần 6: Tổng Kết (2 phút)
```
"Tất cả ứng dụng này được deploy tự động qua Git:
- Developer push code → ArgoCD tự sync
- Canary deployment giúp deploy an toàn
- Prometheus monitor toàn bộ hệ thống
- Infrastructure as Code, GitOps best practices"
```

---

## 🔧 TROUBLESHOOTING TRƯỚC KHI DEMO

### Nếu Pods Không Running
```powershell
# Restart tất cả deployments
kubectl rollout restart deployment frontend -n demo
kubectl rollout restart deployment web -n demo

# Check lại
kubectl get pods -n demo
```

### Nếu Port Forward Bị Lỗi
```powershell
# Tìm và kill process đang dùng port 8081
netstat -ano | findstr :8081
taskkill /F /PID <PID>

# Start lại port forward
kubectl port-forward -n demo svc/frontend 8081:80
```

### Nếu ArgoCD Apps OutOfSync
```powershell
# Sync lại tất cả apps
kubectl patch application frontend -n argocd -p '{"operation":{"initiatedBy":{"username":"admin"},"sync":{"revision":"HEAD"}}}' --type merge

kubectl patch application api -n argocd -p '{"operation":{"initiatedBy":{"username":"admin"},"sync":{"revision":"HEAD"}}}' --type merge
```

### Nếu Cần Rebuild Frontend Image
```powershell
cd d:\Cloud\cloud\w9\lab\gitops-demo

# Clear cache và rebuild
docker builder prune -af
docker build --no-cache -t gitops-frontend:v1 frontend/
minikube -p w9 image load gitops-frontend:v1

# Restart frontend
kubectl rollout restart deployment frontend -n demo
```

---

## 📸 SCREENSHOTS NÊNN CHUẨN BỊ

1. **Frontend UI** - Dashboard với gradient purple
2. **API Response** - JSON response trong UI
3. **ArgoCD UI** - App-of-apps topology
4. **Canary Rollout** - Status với 25%/50%/100%
5. **Prometheus** - Metrics graphs

---

## 💡 CÂU HỎI MENTOR CÓ THỂ HỎI

### Q: "Tại sao dùng Canary Deployment?"
**A:** 
- Deploy an toàn hơn, giảm risk
- Test version mới với một phần traffic trước
- Có thể rollback ngay nếu có lỗi
- Giám sát metrics trong quá trình deploy

### Q: "GitOps khác gì với CI/CD truyền thống?"
**A:**
- Git là single source of truth
- Cluster tự động sync với Git
- Declarative, không imperative
- Có history, dễ audit và rollback

### Q: "Làm sao Nginx proxy hoạt động?"
**A:**
- Frontend pod có 2 container logic: React static files + Nginx
- Nginx config: `/api` → proxy_pass to backend
- Browser gọi relative path `/api`
- Nginx forward request đến backend service

### Q: "Nếu v2 có bug, làm sao rollback?"
**A:**
```bash
# Rollback về version trước
kubectl argo rollouts undo api -n demo

# Hoặc abort canary
kubectl argo rollouts abort api -n demo
```

### Q: "Prometheus scrape metrics như thế nào?"
**A:**
- Tạo ServiceMonitor CRD
- Prometheus Operator tự động discover
- Scrape `/metrics` endpoint mỗi 15s
- Store metrics trong TSDB

---

## ✅ CHECKLIST TRƯỚC KHI DEMO

- [ ] Minikube w9 đang chạy
- [ ] Tất cả pods trong `demo` namespace đều Running
- [ ] ArgoCD applications đều Synced
- [ ] Port forward 8081 hoạt động
- [ ] Frontend UI load được trong browser
- [ ] API call trả về response đúng
- [ ] ArgoCD UI login được (https://localhost:8080)
- [ ] Prometheus UI mở được (port 9090)
- [ ] Đã test canary promote ít nhất 1 lần
- [ ] Git repo có commit mới nhất

---

## 🎯 LỆNH NHANH TRONG DEMO

```powershell
# 1. Start port forward
kubectl port-forward -n demo svc/frontend 8081:80

# 2. Mở frontend
Start-Process "http://localhost:8081"

# 3. Test API
Invoke-WebRequest -Uri http://localhost:8081/api -UseBasicParsing | Select-Object -ExpandProperty Content

# 4. Xem canary status
kubectl argo rollouts get rollout api -n demo

# 5. Promote canary
kubectl argo rollouts promote api -n demo

# 6. Mở ArgoCD
Start-Process "https://localhost:8080"

# 7. Xem pods
kubectl get pods -n demo

# 8. Xem applications
kubectl get applications -n argocd
```

---

## 🚀 CHÚC BẠN DEMO THÀNH CÔNG!

**Tips:**
- Nói rõ ràng, tự tin
- Giải thích "why" không chỉ "what"
- Chuẩn bị trước câu trả lời cho các câu hỏi
- Nếu có lỗi, bình tĩnh troubleshoot
- Show terminal commands, không chỉ click UI

**Good luck! 🍀**
