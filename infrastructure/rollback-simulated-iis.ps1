param(
    [Parameter(Mandatory)][string]$BackupPath
)

$sitePath = "_simulated_iis/Sites/SampleWebApp"

if (-not (Test-Path $BackupPath)) {
    Write-Error "Backup introuvable : $BackupPath"
    exit 1
}

Write-Host "Rollback en cours depuis $BackupPath..." -ForegroundColor Yellow

Remove-Item $sitePath -Recurse -Force
Copy-Item $BackupPath $sitePath -Recurse -Force

Write-Host "Rollback terminé avec succès !" -ForegroundColor Green