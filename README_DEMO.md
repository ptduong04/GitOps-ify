# 🎯 GitOps Demo - Complete Guide

> **Lab:** GitOps với ArgoCD, Argo Rollouts, Prometheus  
> **Student:** [Your Name]  
> **Date:** June 11, 2026

---

## 📖 TÀI LIỆU HƯỚNG DẪN

### Cho Ngày Demo
1. **[DEMO_CHO_MENTOR.md](./DEMO_CHO_MENTOR.md)** ⭐ **ĐỌC ĐẦU TIÊN**
   - Hướng dẫn demo chi tiết từng bước
   - Kịch bản demo 15-20 phút
   - Câu hỏi mentor có thể hỏi + câu trả lời
   - Troubleshooting guide

2. **[DEMO_CHEAT_SHEET.md](./DEMO_CHEAT_SHEET.md)** 📋 **IN RA ĐỂ BÊN CẠNH**
   - Bảng tra cứu lệnh nhanh
   - Expected results
   - Quick troubleshooting

### Cho Sử Dụng Hàng Ngày
3. **[QUICK_START.md](./QUICK_START.md)**
   - Quick start commands
   - Access URLs
   - Basic troubleshooting

4. **[docs/DEMO_STATUS.md](./docs/DEMO_STATUS.md)**
   - Full system status
   - Architecture details
   - Testing procedures

### Scripts & Tools
5. **[pre-demo-check.ps1](./pre-demo-check.ps1)**
   - Health check script
   - Chạy trước khi demo

---

## 🚀 DEMO TRONG 5 PHÚT (TẮT VẮN)

### Bước 1: Chuẩn Bị
```powershell
# Kiểm tra hệ thống
.\pre-demo-check.ps1

# Start port forward (Terminal 1 - để mở)
kubectl port-forward -n demo svc/frontend 8081:80
```

### Bước 2: Mở Applications
```powershell
# Frontend (Terminal 2)
Start-Process "http://localhost:8081"

# ArgoCD (optional)
Start-Process "https://localhost:8080"
# User: admin, Pass: S3Xkm72ZEeG8b6o3
```

### Bước 3: Demo!
1. **Frontend**: Click "Call API" button → Xem response
2. **Canary**: `kubectl argo rollouts get rollout api -n demo`
3. **Promote**: `kubectl argo rollouts promote api -n demo`
4. **ArgoCD**: Show app-of-apps pattern

---

## 📚 NỘI DUNG ĐÃ HOÀN THÀNH

### ✅ Labs Sáng (Labs 0-7)
- Minikube cluster `w9`
- ArgoCD installation & configuration
- App-of-apps pattern
- Web application deployment
- GitOps workflow

### ✅ Labs Chiều (Observability + Canary)
- Prometheus Stack + Grafana
- Argo Rollouts
- Flask API với metrics
- Canary deployment strategy
- ServiceMonitor configuration

### ✅ Bonus Lab (Full-Stack)
- React frontend với modern UI
- Flask backend API
- Nginx reverse proxy
- Full GitOps deployment
- Integration testing

---

## 🏗️ KIẾN TRÚC TỔNG QUAN

```
┌─────────────────────────────────────────────────────┐
│                   User / Mentor                     │
└───────────────────────┬─────────────────────────────┘
                        │
        ┌───────────────┼───────────────┐
        │               │               │
        ▼               ▼               ▼
  Frontend UI    ArgoCD UI      Prometheus UI
 (localhost:8081) (localhost:8080) (localhost:9090)
        │               │               │
        └───────────────┼───────────────┘
                        │
        ┌───────────────┴───────────────┐
        │    Kubernetes Cluster (w9)    │
        │                               │
        │  ┌─────────────────────────┐  │
        │  │   ArgoCD (GitOps)       │  │
        │  │   - App-of-apps         │  │
        │  └──────────┬──────────────┘  │
        │             │                  │
        │  ┌──────────┴──────────────┐  │
        │  │   Demo Namespace        │  │
        │  │  ┌────────────────────┐ │  │
        │  │  │ Frontend (React)   │ │  │
        │  │  │  + Nginx Proxy     │ │  │
        │  │  └────────┬───────────┘ │  │
        │  │           │              │  │
        │  │  ┌────────▼───────────┐ │  │
        │  │  │ Backend API (Flask)│ │  │
        │  │  │  + Argo Rollout    │ │  │
        │  │  │  (Canary: 25→100%) │ │  │
        │  │  └────────────────────┘ │  │
        │  └─────────────────────────┘  │
        │                               │
        │  ┌─────────────────────────┐  │
        │  │ Monitoring Namespace    │  │
        │  │  - Prometheus           │  │
        │  │  - Grafana              │  │
        │  │  - ServiceMonitor       │  │
        │  └─────────────────────────┘  │
        └───────────────────────────────┘
                        │
        ┌───────────────▼───────────────┐
        │   GitHub Repository           │
        │   ptduong04/GitOps-ify        │
        │   - k8s manifests             │
        │   - ArgoCD apps               │
        │   - Source code               │
        └───────────────────────────────┘
```

---

## 🔑 THÔNG TIN QUAN TRỌNG

### Access URLs
| Service | URL | Credentials |
|---------|-----|-------------|
| Frontend UI | http://localhost:8081 | N/A |
| Backend API | http://localhost:8081/api | N/A |
| ArgoCD UI | https://localhost:8080 | admin / S3Xkm72ZEeG8b6o3 |
| Prometheus | http://localhost:9090 | N/A |

### Namespaces
- `demo` - Application workloads
- `argocd` - ArgoCD controller
- `monitoring` - Prometheus stack

### Git Repository
- **URL**: https://github.com/ptduong04/GitOps-ify.git
- **Branch**: main
- **Pattern**: GitOps - Git as source of truth

---

## 📋 CHECKLIST NGÀY DEMO

### Trước Demo (1 ngày trước)
- [ ] Đọc toàn bộ file `DEMO_CHO_MENTOR.md`
- [ ] In file `DEMO_CHEAT_SHEET.md`
- [ ] Practice demo flow 2-3 lần
- [ ] Chuẩn bị câu trả lời cho câu hỏi phổ biến

### Sáng Ngày Demo (30 phút trước)
- [ ] Chạy `minikube -p w9 status` - Check running
- [ ] Chạy `.\pre-demo-check.ps1` - All checks pass
- [ ] Test frontend: Click "Call API" button
- [ ] Test canary: Check rollout status
- [ ] Test ArgoCD: Login và xem apps
- [ ] Chuẩn bị 2 terminals + browser tabs

### Trong Lúc Demo
- [ ] Terminal 1: Port forward (để mở suốt)
- [ ] Terminal 2: Chạy các lệnh demo
- [ ] Browser tab 1: Frontend UI
- [ ] Browser tab 2: ArgoCD UI
- [ ] Cheat sheet để bên cạnh

---

## 🎯 CÁC ĐIỂM NỔI BẬT ĐỂ CHỈ CHO MENTOR

### 1. GitOps Best Practices
- ✅ Git là single source of truth
- ✅ Declarative configuration
- ✅ Auto-sync enabled
- ✅ Self-healing
- ✅ App-of-apps pattern

### 2. Cloud Native Tools
- ✅ Kubernetes orchestration
- ✅ ArgoCD for GitOps
- ✅ Argo Rollouts for progressive delivery
- ✅ Prometheus for monitoring
- ✅ Modern CI/CD pipeline

### 3. Production-Ready Features
- ✅ Canary deployment strategy
- ✅ Health checks
- ✅ Metrics collection
- ✅ Reverse proxy
- ✅ Multi-tier architecture

### 4. Technical Skills Demonstrated
- ✅ Kubernetes resources (Pods, Services, Deployments, Rollouts)
- ✅ Docker containerization
- ✅ Nginx configuration
- ✅ GitOps workflow
- ✅ Monitoring & observability

---

## 💡 TIPS ĐỂ DEMO TỐT

### Trước Khi Nói
1. Thở sâu, tự tin
2. Kiểm tra terminal/browser đã mở đúng
3. Volume speaker đủ nghe
4. Cheat sheet ở vị trí dễ nhìn

### Trong Khi Demo
1. Nói rõ ràng, không nhanh
2. Giải thích "WHY" không chỉ "WHAT"
3. Kết nối với real-world use cases
4. Show terminal commands, không chỉ UI
5. Nếu lỗi, bình tĩnh check cheat sheet

### Khi Trả Lời Câu Hỏi
1. Lắng nghe hết câu hỏi
2. Suy nghĩ 2-3 giây trước khi trả lời
3. Nếu không biết: "Em chưa research phần này, nhưng em sẽ tìm hiểu"
4. Link câu trả lời với demo đã show

---

## 🆘 KHI CÓ VẤN ĐỀ

### Pods Không Chạy
```powershell
kubectl get pods -n demo
kubectl describe pod <pod-name> -n demo
kubectl rollout restart deployment <name> -n demo
```

### Port Forward Bị Ngắt
```powershell
# Tìm và kill
netstat -ano | findstr :8081
taskkill /F /PID <PID>

# Start lại
kubectl port-forward -n demo svc/frontend 8081:80
```

### ArgoCD OutOfSync
- Vào UI → Click app → Click "Sync" → "Synchronize"

### Frontend Không Load
```powershell
# Check service
kubectl get svc frontend -n demo

# Check pods
kubectl get pods -n demo -l app=frontend

# Restart
kubectl rollout restart deployment frontend -n demo
```

---

## 📞 HỖ TRỢ

Nếu cần hỗ trợ trong khi demo:
1. Check `DEMO_CHEAT_SHEET.md` - Quick fixes
2. Check `DEMO_CHO_MENTOR.md` - Troubleshooting section
3. Kubectl logs: `kubectl logs -n demo <pod-name>`

---

## 🎉 KẾT LUẬN

Bạn đã hoàn thành một demo GitOps production-ready với:
- ✅ Full-stack application
- ✅ Progressive delivery (canary)
- ✅ Monitoring & observability
- ✅ GitOps best practices
- ✅ Cloud native tools

**All the best cho demo ngày mai! 🍀**

---

*Generated: June 11, 2026*  
*Repository: https://github.com/ptduong04/GitOps-ify.git*
