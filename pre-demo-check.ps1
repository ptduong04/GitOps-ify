#!/usr/bin/env pwsh
# Pre-Demo Health Check Script
# Chạy script này trước khi demo để đảm bảo mọi thứ hoạt động

Write-Host "`n╔══════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║        GITOPS DEMO - PRE-DEMO HEALTH CHECK         ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

$allGood = $true

# 1. Check Minikube
Write-Host "[1/8] Checking Minikube cluster..." -ForegroundColor Yellow
try {
    $minikubeStatus = minikube -p w9 status 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✓ Minikube cluster 'w9' is running" -ForegroundColor Green
    } else {
        Write-Host "   ✗ Minikube cluster 'w9' is NOT running" -ForegroundColor Red
        Write-Host "     Fix: minikube -p w9 start" -ForegroundColor Gray
        $allGood = $false
    }
} catch {
    Write-Host "   ✗ Cannot check minikube status" -ForegroundColor Red
    $allGood = $false
}

# 2. Check Kubernetes Connection
Write-Host "`n[2/8] Checking Kubernetes connection..." -ForegroundColor Yellow
try {
    $nodes = kubectl get nodes --no-headers 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✓ Connected to Kubernetes cluster" -ForegroundColor Green
    } else {
        Write-Host "   ✗ Cannot connect to Kubernetes" -ForegroundColor Red
        $allGood = $false
    }
} catch {
    Write-Host "   ✗ kubectl command failed" -ForegroundColor Red
    $allGood = $false
}

# 3. Check Demo Namespace Pods
Write-Host "`n[3/8] Checking pods in 'demo' namespace..." -ForegroundColor Yellow
try {
    $pods = kubectl get pods -n demo --no-headers 2>&1
    $runningPods = ($pods | Select-String "Running").Count
    $totalPods = ($pods | Measure-Object).Count
    
    if ($runningPods -eq $totalPods -and $totalPods -gt 0) {
        Write-Host "   ✓ All $totalPods pods are Running" -ForegroundColor Green
        Write-Host "     - Frontend: $(($pods | Select-String 'frontend').Count) pods" -ForegroundColor Gray
        Write-Host "     - API: $(($pods | Select-String 'api-').Count) pods" -ForegroundColor Gray
        Write-Host "     - Web: $(($pods | Select-String 'web-').Count) pods" -ForegroundColor Gray
    } else {
        Write-Host "   ⚠ Only $runningPods/$totalPods pods Running" -ForegroundColor Yellow
        Write-Host "     Check: kubectl get pods -n demo" -ForegroundColor Gray
        $allGood = $false
    }
} catch {
    Write-Host "   ✗ Cannot check pods" -ForegroundColor Red
    $allGood = $false
}

# 4. Check ArgoCD Applications
Write-Host "`n[4/8] Checking ArgoCD applications..." -ForegroundColor Yellow
try {
    $apps = kubectl get applications -n argocd --no-headers 2>&1
    $totalApps = ($apps | Measure-Object).Count
    
    if ($totalApps -gt 0) {
        Write-Host "   ✓ Found $totalApps ArgoCD applications" -ForegroundColor Green
        $apps | ForEach-Object {
            $appName = ($_ -split '\s+')[0]
            Write-Host "     - $appName" -ForegroundColor Gray
        }
    } else {
        Write-Host "   ⚠ No ArgoCD applications found" -ForegroundColor Yellow
        $allGood = $false
    }
} catch {
    Write-Host "   ✗ Cannot check ArgoCD apps" -ForegroundColor Red
    $allGood = $false
}

# 5. Check Frontend Service
Write-Host "`n[5/8] Checking frontend service..." -ForegroundColor Yellow
try {
    $frontendSvc = kubectl get svc frontend -n demo --no-headers 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✓ Frontend service exists" -ForegroundColor Green
        $port = (kubectl get svc frontend -n demo -o jsonpath='{.spec.ports[0].nodePort}')
        Write-Host "     NodePort: $port" -ForegroundColor Gray
    } else {
        Write-Host "   ✗ Frontend service not found" -ForegroundColor Red
        $allGood = $false
    }
} catch {
    Write-Host "   ✗ Cannot check frontend service" -ForegroundColor Red
    $allGood = $false
}

# 6. Check API Service
Write-Host "`n[6/8] Checking API service..." -ForegroundColor Yellow
try {
    $apiSvc = kubectl get svc api -n demo --no-headers 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✓ API service exists" -ForegroundColor Green
    } else {
        Write-Host "   ✗ API service not found" -ForegroundColor Red
        $allGood = $false
    }
} catch {
    Write-Host "   ✗ Cannot check API service" -ForegroundColor Red
    $allGood = $false
}

# 7. Check Argo Rollouts
Write-Host "`n[7/8] Checking Argo Rollouts..." -ForegroundColor Yellow
try {
    $rollout = kubectl get rollout api -n demo --no-headers 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✓ API rollout exists" -ForegroundColor Green
        # Get rollout status
        $status = kubectl argo rollouts status api -n demo --timeout 2s 2>&1
        if ($status -match "Healthy") {
            Write-Host "     Status: Healthy" -ForegroundColor Green
        } elseif ($status -match "Paused") {
            Write-Host "     Status: Paused (Canary in progress)" -ForegroundColor Yellow
        }
    } else {
        Write-Host "   ✗ API rollout not found" -ForegroundColor Red
        $allGood = $false
    }
} catch {
    Write-Host "   ⚠ Cannot check rollout status (kubectl-argo-rollouts plugin may not be installed)" -ForegroundColor Yellow
}

# 8. Test API Connectivity (if port-forward is running)
Write-Host "`n[8/8] Testing API connectivity..." -ForegroundColor Yellow
$portForwardRunning = Get-Process -Name kubectl -ErrorAction SilentlyContinue | Where-Object { $_.CommandLine -match "port-forward.*frontend.*8081" }

if ($portForwardRunning) {
    Write-Host "   ℹ Port forward is already running on 8081" -ForegroundColor Cyan
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8081/api" -UseBasicParsing -TimeoutSec 3 -ErrorAction Stop
        Write-Host "   ✓ API is responding: $($response.Content)" -ForegroundColor Green
    } catch {
        Write-Host "   ⚠ Cannot reach API on localhost:8081" -ForegroundColor Yellow
        Write-Host "     Note: Port forward may need restart" -ForegroundColor Gray
    }
} else {
    Write-Host "   ℹ Port forward is not running (will need to start before demo)" -ForegroundColor Cyan
    Write-Host "     Run: kubectl port-forward -n demo svc/frontend 8081:80" -ForegroundColor Gray
}

# Final Summary
Write-Host "`n╔══════════════════════════════════════════════════════╗" -ForegroundColor Cyan
if ($allGood) {
    Write-Host "║              ✓ ALL CHECKS PASSED! ✓                ║" -ForegroundColor Green
    Write-Host "╚══════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host "`n🚀 Ready for demo! Good luck!`n" -ForegroundColor Green
} else {
    Write-Host "║           ⚠ SOME CHECKS FAILED! ⚠                 ║" -ForegroundColor Yellow
    Write-Host "╚══════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host "`n⚠ Please fix the issues above before demo`n" -ForegroundColor Yellow
}

# Quick start commands
Write-Host "═════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "QUICK START COMMANDS FOR DEMO:" -ForegroundColor Yellow
Write-Host "═════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Start port forward:" -ForegroundColor White
Write-Host "   kubectl port-forward -n demo svc/frontend 8081:80" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Open frontend:" -ForegroundColor White
Write-Host "   Start-Process 'http://localhost:8081'" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Check canary status:" -ForegroundColor White
Write-Host "   kubectl argo rollouts get rollout api -n demo" -ForegroundColor Gray
Write-Host ""
Write-Host "4. Open ArgoCD:" -ForegroundColor White
Write-Host "   Start-Process 'https://localhost:8080'" -ForegroundColor Gray
Write-Host "   (user: admin, pass: S3Xkm72ZEeG8b6o3)" -ForegroundColor Gray
Write-Host ""
Write-Host "═════════════════════════════════════════════════════════`n" -ForegroundColor Cyan
