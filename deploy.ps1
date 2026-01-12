# Script PowerShell para deploy do orquestrador Kubernetes
# Uso: .\deploy.ps1

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "FIAP Cloud Games - Kubernetes Deploy" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar se kubectl está disponível
Write-Host "Verificando kubectl..." -ForegroundColor Yellow
try {
    $kubectlVersion = kubectl version --client --short 2>&1
    Write-Host "✓ kubectl encontrado" -ForegroundColor Green
} catch {
    Write-Host "✗ kubectl não encontrado. Por favor, instale o kubectl." -ForegroundColor Red
    exit 1
}

# Verificar se o cluster está acessível
Write-Host "Verificando conexão com o cluster..." -ForegroundColor Yellow
try {
    $clusterInfo = kubectl cluster-info 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Cluster Kubernetes acessível" -ForegroundColor Green
    } else {
        Write-Host "✗ Não foi possível conectar ao cluster Kubernetes" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "✗ Erro ao verificar cluster" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Aplicando manifestos Kubernetes..." -ForegroundColor Yellow
Write-Host ""

# Aplicar usando Kustomize
kubectl apply -k k8s/

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✓ Deploy concluído com sucesso!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Aguardando pods iniciarem..." -ForegroundColor Yellow
    Start-Sleep -Seconds 5
    
    Write-Host ""
    Write-Host "Status dos pods:" -ForegroundColor Cyan
    kubectl get pods -n fiap-gamestore
    
    Write-Host ""
    Write-Host "Para verificar logs:" -ForegroundColor Cyan
    Write-Host "  kubectl logs -f deployment/users-api -n fiap-gamestore" -ForegroundColor Gray
    Write-Host "  kubectl logs -f deployment/catalog-api -n fiap-gamestore" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Para acessar os serviços:" -ForegroundColor Cyan
    Write-Host "  .\start-gateway.ps1  (Gateway com Swagger unificado - RECOMENDADO)" -ForegroundColor Green
    Write-Host "  Ou individualmente:" -ForegroundColor Gray
    Write-Host "    kubectl port-forward svc/users-api-service 8080:8080 -n fiap-gamestore" -ForegroundColor Gray
    Write-Host "    kubectl port-forward svc/catalog-api-service 8081:8080 -n fiap-gamestore" -ForegroundColor Gray
} else {
    Write-Host ""
    Write-Host "✗ Erro durante o deploy" -ForegroundColor Red
    exit 1
}
