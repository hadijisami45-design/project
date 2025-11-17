# Test CI/CD – SampleWebApp

## Contexte

Ce repository contient une petite application ASP.NET Core (`SampleWebApp`) utilisée pour évaluer la capacité à mettre en place une chaîne CI/CD destinée à automatiser la livraison d’applications Web actuellement déployées manuellement sur IIS Windows Server.

Dans le contexte réel, les applications de l’entreprise sont :

* versionnées dans Git,
* buildées localement,
* puis copiées manuellement dans IIS sur des serveurs Windows.

L’objectif de ce test est d’évaluer votre capacité à industrialiser ce processus avec une démarche CI/CD moderne.

Pour simplifier l’environnement, ce projet utilise un **IIS simulé** (simple dossier local) afin que vous puissiez implémenter la logique de déploiement sans nécessiter un vrai serveur Windows IIS.

---

## Structure du repository

```
Test-CICD/
│
├── SampleWebApp/                    # Application ASP.NET Core
│
├── infrastructure/
│   └── deploy-to-simulated-iis.ps1  # Script PowerShell de déploiement
│
├── artifacts/                       # Sortie de "dotnet publish" (générée)
│
└── _simulated_iis/                  # "IIS" simulé (généré lors du déploiement)
```

---

## IIS simulé

Au lieu d’un vrai serveur IIS, nous utilisons un dossier local :

```
_simulated_iis/Sites/SampleWebApp/
```

Considérez ce dossier comme l’équivalent de :

```
C:\inetpub\wwwroot\SampleWebApp
```

sur un serveur Windows IIS.

---

## Exécution locale de l'application

Depuis le dossier `SampleWebApp`, vous pouvez lancer l'application :

```bash
dotnet run
```

L'application sera alors accessible via une URL locale (ex : [http://localhost:5011](http://localhost:5011)).

---

## Exemple : Build & déploiement manuel (baseline)

Voici les commandes permettant de reproduire le processus manuel actuel (baseline à automatiser).

Depuis la racine du repository :

### 1. Build & publish de l'application

```powershell
dotnet publish .\SampleWebApp\SampleWebApp.csproj -c Release -o .\artifacts\SampleWebApp
```

### 2. Déploiement vers l'IIS simulé

```powershell
.\infrastructure\deploy-to-simulated-iis.ps1 -SourcePath ".\artifacts\SampleWebApp"
```

Le site sera déployé dans :

```
_simulated_iis/Sites/SampleWebApp/
```

---

# Travail demandé

L’objectif est de mettre en place une chaîne CI/CD complète pour `SampleWebApp`, en utilisant **obligatoirement GitHub Actions**.

---

## 1. Pipeline CI avec GitHub Actions (obligatoire)

Vous devez créer un workflow GitHub Actions capable de :

1. Récupérer le code du repository.
2. Restaurer les dépendances .NET.
3. Builder l'application en mode Release.
4. (Optionnel mais apprécié) Exécuter des tests unitaires si vous en ajoutez.
5. Publier un artefact via :

```bash
dotnet publish -c Release -o <dossier>
```

6. Rendre cet artefact disponible en sortie du job CI.

Le pipeline doit tourner sur un **runner Windows**.

---

## 2. Pipeline CD : Déploiement automatisé vers l’IIS simulé

Un second workflow GitHub Actions doit automatiser le déploiement :

1. Télécharger l’artefact produit par la CI.
2. Déployer l’application dans :

```
_simulated_iis/Sites/SampleWebApp/
```

en utilisant :

* soit `infrastructure/deploy-to-simulated-iis.ps1`,
* soit un script PowerShell plus évolué que vous proposez (optionnel).

3. Gérer au moins **une différence de configuration** entre deux environnements (ex : `dev` et `prod` simulés).
4. Fournir un **mécanisme simple de rollback**, par exemple :

   * sauvegarde de la version précédente,
   * copie du dossier avant écrasement,
   * ou autre solution équivalente.

---

## 3. Documentation attendue

Merci de fournir un fichier (README ou autre) expliquant :

* comment fonctionne votre pipeline CI,
* comment fonctionne votre pipeline CD,
* comment déclencher un déploiement,
* comment sont gérés les environnements `dev` et `prod`,
* comment effectuer un rollback.

---

## 4. Mode de livraison

Vous pouvez livrer votre travail sous l’une des formes suivantes :

* nouveau repository GitHub contenant votre solution,
* fork de ce repo,
* Pull Request,
* ou archive ZIP.

Merci de bien inclure :

* vos workflows GitHub Actions,
* vos scripts PowerShell,
* votre documentation.

---

## Checklist 

* [ ] Pipeline CI GitHub Actions fonctionnelle
* [ ] Artifact généré (`dotnet publish`)
* [ ] Pipeline CD GitHub Actions fonctionnelle
* [ ] Déploiement vers IIS simulé
* [ ] Gestion dev/prod simulés
* [ ] Rollback simple disponible
* [ ] Documentation fournie

---
