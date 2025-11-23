param(
    [Parameter(Mandatory = $true)]
    [string]$BackupPath
)

$targetPath = "_simulated_iis/Sites/SampleWebApp"

Write-Host "Rollback de la version actuelle..."

# Supprimer l'ancienne version
if (Test-Path $targetPath) {
    Remove-Item $targetPath -Recurse -Force
}

Write-Host "Restauration depuis : $BackupPath"

# Restaurer le dossier entier SampleWebApp depuis la sauvegarde
Copy-Item $BackupPath $targetPath -Recurse -Force

Write-Host "Rollback terminé avec succès !"
Write-Host "Version restaurée depuis la sauvegarde."