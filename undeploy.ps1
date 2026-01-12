# Script PowerShell para remover o deploy do orquestrador Kubernetes
# Uso: .\undeploy.ps1

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "FIAP Cloud Games - Kubernetes Undeploy" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

$confirmation = Read-Host "Tem certeza que deseja remover todos os recursos? (S/N)"
if ($confirmation -ne 'S' -and $confirmation -ne 's') {
    Write-Host "Operação cancelada." -ForegroundColor Yellow
    exit 0
}

Write-Host "Removendo recursos..." -ForegroundColor Yellow
kubectl delete -k k8s/

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✓ Recursos removidos com sucesso!" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "✗ Erro ao remover recursos" -ForegroundColor Red
    exit 1
}
