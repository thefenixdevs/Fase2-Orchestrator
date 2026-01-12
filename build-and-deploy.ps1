# Script PowerShell para construir imagens e fazer deploy completo
# Uso: .\build-and-deploy.ps1

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "FIAP Cloud Games - Build & Deploy" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Passo 1: Build das imagens
Write-Host "Passo 1: Construindo imagens Docker..." -ForegroundColor Yellow
Write-Host ""

& "$PSScriptRoot\build-images.ps1"

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "✗ Falha ao construir imagens. Abortando deploy." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Passo 2: Deploy no Kubernetes
Write-Host "Passo 2: Fazendo deploy no Kubernetes..." -ForegroundColor Yellow
Write-Host ""

& "$PSScriptRoot\deploy.ps1"

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host "✓ Build e Deploy concluídos com sucesso!" -ForegroundColor Green
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Próximos passos:" -ForegroundColor Cyan
    Write-Host "  1. Aguarde alguns segundos para os pods iniciarem" -ForegroundColor Gray
    Write-Host "  2. Verifique o status: kubectl get pods -n fiap-gamestore" -ForegroundColor Gray
    Write-Host "  3. Acesse os serviços usando port-forward:" -ForegroundColor Gray
    Write-Host "     kubectl port-forward svc/users-api-service 8080:8080 -n fiap-gamestore" -ForegroundColor Gray
    Write-Host "     kubectl port-forward svc/catalog-api-service 8081:8080 -n fiap-gamestore" -ForegroundColor Gray
} else {
    Write-Host ""
    Write-Host "✗ Falha no deploy. Verifique os logs acima." -ForegroundColor Red
    exit 1
}
