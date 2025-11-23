# Pipeline CI/CD - Explication

# CI (Continuous Integration) : Build & Publish

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

**Checkout code**
```yaml
- name: Checkout code
  uses: actions/checkout@v4
```
Le pipeline CI démarre automatiquement dans les cas suivants :
    
    •push sur la branche main

    •pull_request vers la branche main (pour chaque intégration d'une nouvelle branche)


### Jobs principal Build


• Runner utilisé : runs-on: windows-latest

• Le job s'exécute sur une machine virtuelle Windows.


## Étapes du job build



**Checkout code**
```yaml
- name: Checkout code
  uses: actions/checkout@v4
```
Description :

Récupère le code du dépôt dans l’espace de travail du runner pour accéder au code source.

## Setup .NET
**code :**
```yaml
- name: Setup .NET
  uses: actions/setup-dotnet@v4
  with:
    dotnet-version: '8.0.x'
```
Description :
Installe le SDK .NET et configure dotnet dans le PATH.


## Restore dependencies
**Code :**
```yaml
- name: Restore dependencies
  run: dotnet restore ./SampleWebApp/SampleWebApp.csproj
```
Description :

Télécharge et installe tous les packages NuGet nécessaires au projet et prépare les dépendances pour la compilation.

## . Build Release
**Code :**
```yaml
- name: Build Release
  run: dotnet build ./SampleWebApp/SampleWebApp.csproj -c Release --no-restore
```
Description :

Compile le code source en assemblies (.dll) et génère les dossiers bin/Release et bin/Debug.
L’option --no-restore évite de restaurer à nouveau les packages déjà installés.

## Test
**Code :**
```yaml
- name: Test
  run: dotnet test --no-build --verbosity normal
```
Description :

Exécute les tests du projet.
    
    •--no-build évite la recompilation déjà faite par dotnet build
    
    •--verbosity normal augmente la verbosité pour faciliter le debug en CI


## Publish
**Code :**
```yaml
- name: Publish
  run: dotnet publish ./SampleWebApp/SampleWebApp.csproj -c Release -o ./artifacts/SampleWebApp --no-build
```

Description :

Génère une sortie prête à être déployée dans le dossier ./artifacts/SampleWebApp.

# Upload artifact
**Code :**
```yaml
- name: Upload artifact
  uses: actions/upload-artifact@v4
  with:
    name: SampleWebApp-publish
    path: ./artifacts/SampleWebApp/**
    retention-days: 7
```

Description :

Stocke la sortie publish comme artefact joignable depuis l’interface GitHub Actions pendant 7 jours.



# CD (Continuous Deployment)

# Déclencheur manuel
**Code :**
```yaml
on:
  workflow_dispatch:
    inputs:
      environment:
        description: 'Environnement de déploiement'
        required: true
        default: 'dev'
        type: choice
        options: [dev, prod]
```
Description :

L’utilisateur choisit l’environnement (dev ou prod).
La valeur choisie est accessible via ${{ inputs.environment }}.


## Étapes du workflow CD
1. Créer la structure IIS simulée
**Code :**
```yaml
- name: Create simulated IIS structure
  run: mkdir -p _simulated_iis/Backups
```

Description :
Crée un dossier Backups pour stocker les sauvegardes avant déploiement.


## Backup de la version actuelle
**Code :**
```yaml
- name: Backup current version
  run: |
    $date = Get-Date -Format "yyyyMMdd-HHmmss"
    $backupPath = "_simulated_iis/Backups/SampleWebApp-$date-${{ github.sha }}"
    if (Test-Path "_simulated_iis/Sites/SampleWebApp") {
      Copy-Item "_simulated_iis/Sites/SampleWebApp" $backupPath -Recurse -Force
      echo "BACKUP_PATH=$backupPath" >> $env:GITHUB_ENV
    }
```

Description :

Vérifie si une version précédente existe et crée un backup avant le déploiement.
Expose la variable BACKUP_PATH pour les étapes suivantes.


## Copier la configuration selon l’environnement
**Code :**
```yaml
- name: Copy environment-specific config
  run: |
    Copy-Item "environments/appsettings.${{ inputs.environment }}.json" "./artifacts/SampleWebApp/appsettings.json" -Force
```

Description :

Choisit le fichier de configuration correspondant à l’environnement (dev ou prod) et le copie dans les artefacts.

## Déployer vers IIS simulé
**Code :**
```yaml
- name: Deploy to simulated IIS
  run: |
    Copy-Item "./artifacts/SampleWebApp/*" "_simulated_iis/Sites/SampleWebApp/" -Recurse -Force
```

Description :
Copie les fichiers publiés dans le dossier IIS simulé.

## Afficher succès et informations rollback
**Code :**
```yaml
- name: Display success + rollback info
  run: |
    echo "Déploiement réussi en ${{ inputs.environment }} !"
```
Description :
Affiche un message de succès 

# Comment declecher un déploiement ?

**Code :**
```yaml
on:
  workflow_dispatch:
    inputs:
      environment:
        description: 'Environnement de déploiement'
        required: true
        default: 'dev'
        type: choice
        options: [dev, prod]
```

--> Ce workflow permet de lancer le déploiement manuellement en cliquant sur “Run workflow” dans l’interface GitHub Actions, en choisissant l’environnement dev ou prod.


# comment sont gérés les environnements dev et prod ?

les environnements dev et prod sont gérés via une sélection manuelle dans le workflow GitHub 
Actions. Le déploiement lui-même reste identique dans sa structure. Le fichier créer 
(appsettings.dev.json ou appsettings.prod.json) est ensuite copié dans le dossier des artefacts 
de l’application, mais la configuration spécifique garantit que le comportement de l’application 
est adapté à l’environnement. garantissant un déploiement sûr et adapté à chaque contexte 

# comment effectuer un rollback ?

Le rollback sert à revenir à l’ancienne version qui fonctionnait si la nouvelle ne fonctionne pas.

On crée un fichier rollback qui sera exécuté manuellement depuis l’interface GitHub Actions, dans Rollback - Simulated IIS, où l’on indiquera le chemin du backup créé lors de l’étape Backup current version.

Commande pour effectuer le rollback :
```powershell
pwsh ./infrastructure/rollback-simulated-iis.ps1 -BackupPath "${{ github.event.inputs.backup-path }}"
```

→ Cette commande permet de restaurer l’ancienne version qui fonctionnait correctement



Sami hadiji
