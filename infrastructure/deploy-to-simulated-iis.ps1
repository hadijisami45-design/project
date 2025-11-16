param(
    [Parameter(Mandatory = $true)]
    [string]$SourcePath,  

    [string]$SiteName = "SampleWebApp",
    [string]$SimulatedRoot = "_simulated_iis"
)

$repoRoot = Join-Path $PSScriptRoot ".."

# Chemin final "type IIS": _simulated_iis/Sites/SampleWebApp
$targetPath = Join-Path $repoRoot "$SimulatedRoot\Sites\$SiteName"

Write-Host "Déploiement du site '$SiteName' depuis '$SourcePath' vers '$targetPath'..."

# Supprime l'ancienne version si elle existe
if (Test-Path $targetPath) {
    Write-Host "Suppression de l'ancienne version..."
    Remove-Item -Recurse -Force $targetPath
}

# Crée le dossier cible
New-Item -ItemType Directory -Path $targetPath -Force | Out-Null

# Copie les fichiers publiés
Copy-Item -Path (Join-Path $SourcePath "*") -Destination $targetPath -Recurse

Write-Host "Déploiement terminé."
Write-Host "Les fichiers sont disponibles dans : $targetPath"
