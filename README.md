# GitOps Demo with ArgoCD

This repository demonstrates GitOps principles using ArgoCD.

## Structure

```
gitops-demo/
├── k8s/              # Kubernetes manifests
├── argocd/
│   └── apps/         # ArgoCD Application definitions
├── app/              # Application source code (Lab 7)
└── .github/
    └── workflows/    # CI/CD pipelines (Lab 7)
```

## Labs

Follow the labs in order:

- **Lab 0**: Setup cluster + Git
- **Lab 1**: Install ArgoCD
- **Lab 2**: Create Application
- **Lab 3**: Auto-sync & Self-heal
- **Lab 4**: Git Rollback
- **Lab 5**: App-of-Apps
- **Lab 6**: Sync Waves
- **Lab 7**: CI/CD Integration

## Quick Start

```bash
# Start cluster
minikube start -p w9 --driver=docker --cpus=4 --memory=4096

# Install ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for pods
kubectl get pods -n argocd -w

# Access UI
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Get password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

Login: https://localhost:8080
- Username: `admin`
- Password: (from above command)

---

**GitOps Principles:**
1. Declarative
2. Versioned
3. Pulled automatically
4. Continuously reconciled
