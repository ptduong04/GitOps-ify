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

