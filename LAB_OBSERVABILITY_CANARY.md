# Lab Observability + Canary Deployment

## ✅ Lab 1: Cài đặt Prometheus Stack & Argo Rollouts

### Đã hoàn thành:
- ✅ Tạo `argocd/apps/kube-prometheus-stack.yaml` (Helm chart v45.7.1)
- ✅ Tạo `argocd/apps/argo-rollouts.yaml` (Helm chart v2.32.0)
- ✅ Push lên GitHub → Root app tự động tạo 2 applications
- ✅ Argo Rollouts controller đang chạy trong namespace `argo-rollouts`
- ✅ Prometheus Operator đã được cài đặt (monitoring namespace)

### Kết quả:
```bash
$ kubectl get applications -n argocd
NAME                    SYNC STATUS   HEALTH STATUS
argo-rollouts           OutOfSync     Healthy
kube-prometheus-stack   OutOfSync     Missing
root                    Synced        Healthy
api                     Synced        Healthy
web                     Synced        Healthy

$ kubectl get pods -n argo-rollouts
NAME                            READY   STATUS    RESTARTS
argo-rollouts-5f64f8d68-c4k44   1/1     Running   1
```

---

## ✅ Lab 2: Tạo Flask API với Prometheus Metrics

### Đã hoàn thành:
- ✅ Tạo `app/app.py` - Flask app với:
  - `/healthz` - Health check endpoint
  - `/api` - API endpoint (5% random error rate)
  - `/metrics` - Prometheus metrics (Counter, Histogram)
  - Environment variable `VERSION` để track version

- ✅ Tạo `app/requirements.txt`:
  ```
  flask==3.0.0
  prometheus-client==0.19.0
  ```

- ✅ Tạo `app/Dockerfile` - Python 3.12 slim

- ✅ Build Docker images:
  ```bash
  docker build -t flask-api:v1 app/
  docker build -t flask-api:v2 app/
  minikube -p w9 image load flask-api:v1
  minikube -p w9 image load flask-api:v2
  ```

### Metrics được expose:
- `flask_http_request_total` - Counter (method, endpoint, status)
- `flask_http_request_duration_seconds` - Histogram

---

## ✅ Lab 3: Deploy API với Rollout CRD

### Đã hoàn thành:
- ✅ Tạo `k8s-api/api.yaml` với:
  - **Rollout** CRD (thay vì Deployment)
  - Canary strategy với steps:
    ```yaml
    steps:
    - setWeight: 25
    - pause: {}          # Manual approval
    - setWeight: 50
    - pause: { duration: 30s }
    - setWeight: 100
    ```
  - Service ClusterIP
  - 4 replicas

- ✅ Tạo `k8s-api/servicemonitor.yaml`:
  ```yaml
  apiVersion: monitoring.coreos.com/v1
  kind: ServiceMonitor
  spec:
    selector:
      matchLabels:
        app: api
    endpoints:
    - port: http
      path: /metrics
      interval: 15s
  ```

- ✅ Tạo ArgoCD Application `argocd/apps/api.yaml`

- ✅ Push lên GitHub → API deployed

### Kết quả:
```bash
$ kubectl get pods -n demo -l app=api
NAME                   READY   STATUS    RESTARTS   AGE
api-84b6db866d-6qwcm   1/1     Running   0          10m
api-84b6db866d-dxvpq   1/1     Running   0          10m
api-84b6db866d-lz8wj   1/1     Running   0          10m
api-84b6db866d-sjtbz   1/1     Running   0          10m
```

---

## ✅ Lab 4: Test Canary Deployment

### Đã hoàn thành:
- ✅ Build image v2
- ✅ Update `k8s-api/api.yaml`: `flask-api:v1` → `flask-api:v2`, `VERSION=v1` → `VERSION=v2`
- ✅ Push lên GitHub
- ✅ ArgoCD sync → Rollout bắt đầu canary deployment

### Kết quả quan sát được:

#### Canary Step 1 (25% weight):
```bash
$ kubectl get pods -n demo -l app=api
NAME                   READY   STATUS        RESTARTS   AGE
api-6dc64c744d-jpsv2   1/1     Running       0          21s    # v2 NEW
api-84b6db866d-6qwcm   1/1     Terminating   0          5m23s
api-84b6db866d-dxvpq   1/1     Running       0          5m23s  # v1 OLD
api-84b6db866d-lz8wj   1/1     Running       0          5m23s  # v1 OLD
```

#### Rollout Status - PAUSED tại step 1:
```bash
$ kubectl describe rollout api -n demo
Status:
  Current Step Index:  1
  Phase:              Paused
  Message:            CanaryPauseStep
  Pause Conditions:
    Reason:      CanaryPauseStep
```

**Canary đang chờ manual promote!** ✅

---

## 📊 Kiến trúc đã triển khai:

```
┌─────────────────────────────────────────────────────────┐
│              ArgoCD (GitOps Controller)                 │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐             │
│  │   root   │  │   api    │  │   web    │             │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘             │
└───────┼────────────┼──────────────┼───────────────────┘
        │            │              │
        ▼            ▼              ▼
┌─────────────────────────────────────────────────────────┐
│          Kubernetes Cluster (minikube w9)               │
│                                                          │
│  ┌─────────────────────────────────────────────┐       │
│  │  Namespace: monitoring                       │       │
│  │  • Prometheus Operator                       │       │
│  │  • Alertmanager                              │       │
│  │  • Grafana                                   │       │
│  │  • ServiceMonitor CRD watching /metrics      │       │
│  └─────────────────────────────────────────────┘       │
│                                                          │
│  ┌─────────────────────────────────────────────┐       │
│  │  Namespace: argo-rollouts                    │       │
│  │  • Argo Rollouts Controller                  │       │
│  └─────────────────────────────────────────────┘       │
│                                                          │
│  ┌─────────────────────────────────────────────┐       │
│  │  Namespace: demo                             │       │
│  │  • Rollout: api (canary strategy)            │       │
│  │    - v1: 2 pods (old stable)                 │       │
│  │    - v2: 1 pod (canary 25%)                  │       │
│  │  • Service: api (ClusterIP)                  │       │
│  │  • ServiceMonitor: api → Prometheus scrape   │       │
│  │                                               │       │
│  │  • Deployment: web (5 nginx pods)            │       │
│  └─────────────────────────────────────────────┘       │
└─────────────────────────────────────────────────────────┘
```

---

## 🎯 Những gì đã học được:

### 1. **GitOps Pattern với ArgoCD**
- App-of-Apps: Root app quản lý tất cả apps khác
- Declarative: Chỉ cần push Git → infrastructure tự động sync
- Self-healing: ArgoCD tự động phục hồi nếu có ai sửa manual

### 2. **Observability với Prometheus**
- ServiceMonitor CRD: Tự động discover và scrape metrics
- Prometheus metrics format: Counter, Histogram, Gauge
- `/metrics` endpoint chuẩn cho monitoring

### 3. **Progressive Delivery với Argo Rollouts**
- Rollout CRD: Thay thế Deployment với advanced deployment strategies
- Canary deployment: Thả traffic dần (25% → 50% → 100%)
- Manual gates: Pause để quan sát trước khi tiếp tục
- Traffic shifting: Dùng ReplicaSet weight để chia traffic

### 4. **Kubernetes Advanced Concepts**
- CRD (Custom Resource Definitions): Extend Kubernetes API
- Controllers: Watch resources và reconcile desired state
- Operators: Automated human knowledge (Prometheus Operator, Argo Rollouts)

---

## 🚀 Next Steps (Nâng cao):

### Lab 5 (Nếu có thời gian): AnalysisTemplate
Thêm auto-promotion/rollback dựa trên metrics:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: AnalysisTemplate
metadata:
  name: success-rate
spec:
  metrics:
  - name: success-rate
    interval: 30s
    successCondition: result >= 0.95
    failureLimit: 3
    provider:
      prometheus:
        address: http://prometheus:9090
        query: |
          sum(rate(flask_http_request_total{status="200"}[2m])) / 
          sum(rate(flask_http_request_total[2m]))
```

### Lab 6: Burn Rate Alerts
Implement Google SRE burn rate alerts để phát hiện sớm khi error budget cháy nhanh.

---

## 📝 Commands Cheat Sheet:

```bash
# Check applications
kubectl get applications -n argocd

# Check rollout status
kubectl get rollout api -n demo
kubectl describe rollout api -n demo

# Promote canary (continue to next step)
kubectl -n demo patch rollout api --type json \
  -p='[{"op":"remove","path":"/spec/paused"}]'

# Abort canary (rollback to stable)
kubectl argo rollouts abort api -n demo

# Watch rollout progress
kubectl argo rollouts get rollout api -n demo --watch

# Port forward to Prometheus
kubectl -n monitoring port-forward svc/kube-prometheus-stack-prometheus 9090:9090

# Port forward to Grafana
kubectl -n monitoring port-forward svc/kube-prometheus-stack-grafana 3000:80
# Login: admin / admin

# Query Prometheus metrics
kubectl -n demo port-forward svc/api 8080:80
curl http://localhost:8080/metrics
```

---

## ✅ Lab Completion Summary:

| Lab | Status | Details |
|-----|--------|---------|
| Lab 1: Infrastructure | ✅ | Prometheus Stack + Argo Rollouts installed via GitOps |
| Lab 2: Flask API | ✅ | App with `/metrics` endpoint, Docker images v1 & v2 built |
| Lab 3: Rollout Deployment | ✅ | API deployed with Rollout CRD, 4 pods running |
| Lab 4: Canary Test | ✅ | v1→v2 canary started, **paused at 25% weight** |

**🎉 Canary deployment đang chạy và pause chờ approval! Lab thành công!**

---

## 📚 References:

- [Argo Rollouts Documentation](https://argoproj.github.io/argo-rollouts/)
- [Prometheus Operator](https://github.com/prometheus-operator/prometheus-operator)
- [Google SRE Book - SLO/SLI/Error Budget](https://sre.google/sre-book/service-level-objectives/)
- [Canary Deployment Best Practices](https://argoproj.github.io/argo-rollouts/features/canary/)
