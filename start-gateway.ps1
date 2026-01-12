# Script PowerShell para iniciar port-forward do Gateway automaticamente
# Uso: .\start-gateway.ps1

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "FIAP Cloud Games - Gateway Port-Forward" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar se o namespace existe
$namespace = "fiap-gamestore"
$namespaceExists = kubectl get namespace $namespace -o name 2>$null

if (-not $namespaceExists) {
    Write-Host "[ERRO] Namespace '$namespace' não encontrado." -ForegroundColor Red
    Write-Host "Execute primeiro: kubectl apply -k k8s/" -ForegroundColor Yellow
    exit 1
}

# Verificar se o service existe
$serviceExists = kubectl get service gateway-api-service -n $namespace -o name 2>$null

if (-not $serviceExists) {
    Write-Host "[ERRO] Service 'gateway-api-service' não encontrado no namespace '$namespace'." -ForegroundColor Red
    Write-Host "Execute primeiro: kubectl apply -k k8s/" -ForegroundColor Yellow
    exit 1
}

Write-Host "[OK] Iniciando port-forward do Gateway..." -ForegroundColor Green
Write-Host ""
Write-Host "Gateway disponível em: http://localhost:5005" -ForegroundColor Cyan
Write-Host "Swagger disponível em: http://localhost:5005" -ForegroundColor Cyan
Write-Host ""
Write-Host "Pressione Ctrl+C para parar o port-forward" -ForegroundColor Yellow
Write-Host ""

# Iniciar port-forward
kubectl port-forward -n $namespace svc/gateway-api-service 5005:8080
