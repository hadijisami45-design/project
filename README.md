# Test CI/CD – SampleWebApp

## Contexte

Ce repository contient une petite application ASP.NET Core (`SampleWebApp`) utilisée pour évaluer la capacité à mettre en place une chaîne CI/CD destinée à automatiser la livraison d’applications Web actuellement déployées manuellement sur IIS Windows Server.

Dans le contexte réel, les applications de l’entreprise sont :
- versionnées dans Git,
- buildées localement,
- puis copiées manuellement dans IIS sur des serveurs Windows.

L’objectif de ce test est d’évaluer votre capacité à industrialiser ce processus avec une démarche CI/CD moderne.

Pour simplifier l’environnement, ce projet utilise un **IIS simulé** (simple dossier local) afin que vous puissiez implémenter la logique de déploiement sans nécessiter un vrai serveur Windows IIS.

---

## Structure du repository

Test-CICD/
│
├── SampleWebApp/ # Application ASP.NET Core
│
├── infrastructure/
│ └── deploy-to-simulated-iis.ps1 # Script PowerShell de déploiement
│
├── artifacts/ # Sortie de "dotnet publish" (générée)
│
└── _simulated_iis/ # "IIS" simulé (généré lors du déploiement)


---

## IIS simulé

Au lieu d’un vrai serveur IIS, nous utilisons un dossier local :

_simulated_iis/Sites/SampleWebApp/


Considérez ce dossier comme l’équivalent de :

C:\inetpub\wwwroot\SampleWebApp


sur un serveur Windows IIS.

---

## Exécution locale de l'application

Depuis le dossier `SampleWebApp`, vous pouvez lancer l'application :

```bash
dotnet run

L'application sera alors accessible via une URL locale (ex : http://localhost:5011).


Exemple : Build & Déploiement manuel (baseline)

Voici les commandes permettant de reproduire le processus manuel actuel (baseline à automatiser).

Depuis la racine du repository :

1. Build & publish de l'application

dotnet publish .\SampleWebApp\SampleWebApp.csproj -c Release -o .\artifacts\SampleWebApp

2. Déploiement vers l'IIS simulé

.\infrastructure\deploy-to-simulated-iis.ps1 -SourcePath ".\artifacts\SampleWebApp"

Le site sera déployé dans :

_simulated_iis/Sites/SampleWebApp/


