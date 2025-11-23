# Pipeline CI/CD - Explication

## CI (Continuous Integration) : Build & Publish

**Nom du workflow :** `CI – Build & Publish`

### Déclencheurs

Le pipeline CI démarre automatiquement dans les cas suivants :  
- **push** sur la branche `main`  
- **pull_request** vers la branche `main` (pour chaque intégration d'une nouvelle branche)

### Jobs

#### Job principal : Build

- **Runner utilisé :** `runs-on: windows-latest`  
  Le job s'exécute sur une machine virtuelle Windows.

#### Étapes (`steps`) du job build

1. **Checkout code**
```yaml
- name: Checkout code
  uses: actions/checkout@v4
Récupère le code du dépôt dans l’espace de travail du runner pour accéder au code source.

Setup .NET

yaml
Copier le code
- name: Setup .NET
  uses: actions/setup-dotnet@v4
  with:
    dotnet-version: '8.0.x'
Installe le SDK .NET.

actions/setup-dotnet télécharge et configure la version demandée dans le PATH pour que dotnet soit disponible.

Restore dependencies

yaml
Copier le code
- name: Restore dependencies
  run: dotnet restore ./SampleWebApp/SampleWebApp.csproj
Télécharge et installe tous les packages et dépendances nécessaires au projet (NuGet).

Prépare les dépendances pour la compilation.

Build Release

yaml
Copier le code
- name: Build Release
  run: dotnet build ./SampleWebApp/SampleWebApp.csproj -c Release --no-restore
Compile le code source en assemblies (.dll) et génère les dossiers bin/Release et bin/Debug.

L’option --no-restore indique de ne pas restaurer les packages déjà installés.

Test

yaml
Copier le code
- name: Test
  run: dotnet test --no-build --verbosity normal
Exécute les tests du projet.

--no-build évite la recompilation déjà faite par dotnet build.

--verbosity normal augmente la verbosité pour faciliter le debug en CI.

Publish

yaml
Copier le code
- name: Publish
  run: dotnet publish ./SampleWebApp/SampleWebApp.csproj -c Release -o ./artifacts/SampleWebApp --no-build
Génère une sortie prête à être déployée.

L’option -o ./artifacts/SampleWebApp place la sortie dans le dossier ./artifacts/SampleWebApp.

Upload artifact

yaml
Copier le code
- name: Upload artifact
  uses: actions/upload-artifact@v4
  with:
    name: SampleWebApp-publish
    path: ./artifacts/SampleWebApp/**
    retention-days: 7
Stocke la sortie publish comme artefact joignable depuis l’interface GitHub Actions.

Les artefacts sont conservés pendant 7 jours.

CD (Continuous Deployment)
Déclencheur
Le déploiement est déclenché manuellement via workflow_dispatch :

yaml
Copier le code
on:
  workflow_dispatch:
    inputs:
      environment:
        description: 'Environnement de déploiement'
        required: true
        default: 'dev'
        type: choice
        options: [dev, prod]
L’utilisateur doit choisir l’environnement : dev ou prod.

La valeur choisie est accessible via ${{ inputs.environment }}.

Étapes du workflow CD
Créer la structure IIS simulée

yaml
Copier le code
- name: Create simulated IIS structure
  run: mkdir -p _simulated_iis/Backups
Crée un dossier Backups pour stocker les sauvegardes avant déploiement.

Backup de la version actuelle

yaml
Copier le code
- name: Backup current version
  run: |
    $date = Get-Date -Format "yyyyMMdd-HHmmss"
    $backupPath = "_simulated_iis/Backups/SampleWebApp-$date-${{ github.sha }}"
    if (Test-Path "_simulated_iis/Sites/SampleWebApp") {
      Copy-Item "_simulated_iis/Sites/SampleWebApp" $backupPath -Recurse -Force
      echo "BACKUP_PATH=$backupPath" >> $env:GITHUB_ENV
    }
Vérifie si une version précédente existe et crée un backup avant le déploiement.

Expose la variable BACKUP_PATH pour les étapes suivantes.

Copier la configuration selon l’environnement

yaml
Copier le code
- name: Copy environment-specific config
  run: |
    Copy-Item "environments/appsettings.${{ inputs.environment }}.json" "./artifacts/SampleWebApp/appsettings.json" -Force
Choisit le fichier de configuration correspondant à l’environnement (dev ou prod) et le copie dans les artefacts.

Déployer vers IIS simulé

yaml
Copier le code
- name: Deploy to simulated IIS
  run: |
    Copy-Item "./artifacts/SampleWebApp/*" "_simulated_iis/Sites/SampleWebApp/" -Recurse -Force
Copie les fichiers publiés dans le dossier IIS simulé.

Afficher succès et informations rollback

yaml
Copier le code
- name: Display success + rollback info
  run: |
    echo "Déploiement réussi en ${{ inputs.environment }} !"
    echo "Pour rollback : ./infrastructure/rollback-simulated-iis.ps1 -BackupPath '$env:BACKUP_PATH'"
Affiche un message de succès.

Fournit la commande PowerShell pour effectuer un rollback si nécessaire.

Gestion des environnements dev et prod
Les environnements sont sélectionnés manuellement dans le workflow GitHub Actions.

Le déploiement reste identique, mais le fichier de configuration choisi (appsettings.dev.json ou appsettings.prod.json) adapte le comportement de l’application à l’environnement.

Rollback
Le rollback permet de revenir à la version précédente en cas de problème avec la nouvelle version.

Il s’effectue via un fichier PowerShell exécuté manuellement dans GitHub Actions :

powershell
Copier le code
pwsh ./infrastructure/rollback-simulated-iis.ps1 -BackupPath "${{ github.event.inputs.backup-path }}"
Le chemin de backup utilisé est celui créé lors de l’étape Backup current version