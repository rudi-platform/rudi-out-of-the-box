<br>
<p align="center">
  <a href="https://rudi.rennesmetropole.fr/">
  <img src="https://blog.rudi.bzh/wp-content/uploads/2020/11/logo_bleu_orange.svg" width=100px alt="Rudi logo" />  </a>
</p>

<h2 align="center" >Rudi Out of the Box 📦</h3>
<p align="center">La version dockerisée du Portail Rudi permettant de tester le logiciel en local.</p>

<p align="center"><a href="https://rudi.rennesmetropole.fr/">🌐 Instance de Rennes Métropole</a> · <a href="https://doc.rudi.fr/">📚 Documentation</a> ·  <a href="https://blog.rudi.bzh/">📰 Blog</a> ·  <a href="https://rudi.fr/yeswiki">🔎 Wiki</a> </p>

</div>

## Lancer Rudi en local 🖥️

### Avant de commencer 

#### Prérequis logiciels

Pour faire tourner RUDI Out-Of-The-Box sur votre machine, vous aurez besoin de :
- [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) - Pour récupérer les fichiers 
- [Git LFS](https://git-lfs.com/) - Pour gérer les grands fichiers avec Git - [Guide d'installation sous Linux](https://docs.github.com/en/repositories/working-with-files/managing-large-files/installing-git-large-file-storage?platform=linux)
- [Docker Engine](https://docs.docker.com/engine/install/) - Pour la containerisation
- [Docker Compose](https://docs.docker.com/compose/install/) - Pour tout orchestrer [Guide d'installation sous Linux](https://docs.docker.com/compose/install/#plugin-linux-only)

> _NOTE :_ Il n'est pas nécessaire de disposer de Docker Desktop pour faire tourner RUDI sur votre machine. En effet, Docker Desktop n'est gratuit que pour les utilisateurs individuels, pas pour les organisations. Cf. [Docker Pricing](https://www.docker.com/pricing/) pour plus d'informations.

#### Prérequis techniques

Pour faire tourner RUDI Out-Of-The-Box sur votre machine, vous aurez besoin au minimum de :
- 24Go à 32Go de RAM
- 2 à 4 CPU 1Core
- 4Go d'espace disque disponible
- une connexion internet fonctionnelle (ADSL 1 minimum)

### 1. Récupérez le code et donnez les droits d'accès nécessaires

```bash
git clone https://github.com/rudi-platform/rudi-out-of-the-box.git
cd rudi-out-of-the-box
git lfs pull
chmod -R 777 data
chmod -R 755 config
```

### 2. Configurez votre environnement

Jetez un œil au fichier `.env` :
- La variable `base_dn` définit le nom de votre serveur RUDI (par défaut : `localhost`)
- Vous voulez utiliser un nom personnalisé ? Ajoutez dans votre fichier hosts :

```
<ip> dataverse.<votre_nom> magnolia.<votre_nom> rudi.<votre_nom>
```

Veuillez également consulter le document [Comment changer de host dans Magnolia ?](./documentation/cookbook/configuration-magnolia.md)

### 3. Lancez les services

Une seule commande pour tout démarrer :

```bash
docker compose -f .\docker-compose-magnolia.yml \
               -f .\docker-compose-rudi.yml \
               -f .\docker-compose-dataverse.yml \
               -f .\docker-compose-network.yml \
               --profile "*" \
               up -d
```

Cette commande démarrera les conteneurs en arrière-plan.

Vous pouvez lancer uniquement les services qui vous intéressent grâce à l'option `--profile`. 

### Où trouver quoi ? 🔎

- RUDI vous attend sur `http://rudi.<votre_nom>/` (ou l'adresse définie dans votre `.env`)
- Le catalogue Dataverse : `http://dataverse.<votre_nom>`
- Le CMS Magnolia : `http://magnolia.<votre_nom>`
- Les services RUDI : `http://rudi.<votre_nom>/<service>`

Vous trouverez l'ensemble des identifiants et mots de passe préconfigurés dans la [page dédiée](./documentation/identifiants.md)

### Les commandes utiles

Besoin de tout arrêter (avec conservation des données saisies) ?

```bash
docker compose -f .\docker-compose-magnolia.yml \
               -f .\docker-compose-rudi.yml \
               -f .\docker-compose-dataverse.yml \
               -f .\docker-compose-network.yml \
               --profile "*" \
               stop
```

Besoin de tout arrêter (avec perte des données saisies) ?

```bash
docker compose -f .\docker-compose-magnolia.yml \
               -f .\docker-compose-rudi.yml \
               -f .\docker-compose-dataverse.yml \
               -f .\docker-compose-network.yml \
               --profile "*" \
               down
```

Envie de tout reconstruire ?

```bash
docker compose -f .\docker-compose-magnolia.yml \
               -f .\docker-compose-rudi.yml \
               -f .\docker-compose-dataverse.yml \
               -f .\docker-compose-network.yml \
               --profile "*" \
               up --build
```

Juste reconstruire les images ?

```bash
docker compose -f .\docker-compose-magnolia.yml \
               -f .\docker-compose-rudi.yml \
               -f .\docker-compose-dataverse.yml \
               -f .\docker-compose-network.yml \
               --profile "*" \
               build
```


## Structure du projet

Voici un aperçu de la structure des répertoires et fichiers du projet :

```
├── config/ : Contient les données de configuration et d'initialisation (en lecture seule) des différents containers.
├── data/ : Contient les données (en lecture/écriture) nécessaires au bon fonctionnement. A terme, devrait contenir seulement une structure de dossier vide.
├── image/ : Contient les informations pour construire certaines images "à la volée" depuis des images publiques.
└── .env : Exemple de fichier d'environnement
```

## Procédures spécifiques

- [Comment passer une instance Roob en production ?](./documentation/cookbook/roob-to-prod.md)
- [Comment mettre en place un certificat SSL pour traefik ?](./documentation/cookbook/treafik-certificat-ssl.md)
- [Comment passer de traefik à Apache ?](./documentation/cookbook/treafik-to-apache.md)
- [Comment configurer les logs ?](./documentation/cookbook/configuration-logs.md)
- [Comment changer de host dans Magnolia ?](./documentation/cookbook/configuration-magnolia.md)
- [Comment configurer l'envoi de mails ?](./documentation/cookbook/configuration-mail.md)
- [Comment générer une clé privée persistée pour les certificats des JWT ?](./documentation/cookbook/configuration-acl-jwt.md)
- [Comment faire persister mes données (RUDI, Dataverse, Magnolia) ?](./documentation/cookbook/data-persistence.md)
- [Comment séparer le déploiement de Dataverse sur un autre serveur ?](./documentation/cookbook/server-dataverse.md)
- [Comment séparer le déploiement d'un des microservices RUDI sur un autre serveur ?](./documentation/cookbook/server-microservice-rudi.md)
- [Comment utiliser un serveur de base de données séparé ?](./documentation/cookbook/server-database.md)
- [Comment personnaliser le nom de mon instance RUDI ROOB ?](./documentation/cookbook/configuration-usage-name.md)
- [Comment personnaliser la page d'accueil de mon instance RUDI ROOB ?](./documentation/cookbook/configuration-welcome-page.md)
- [Comment modifier le contenu du sitemap de mon instance RUDI ROOB ?](./documentation/cookbook/configuration-sitemap.md)
- [Comment charger un script javascript personnalisé dans mon instance RUDI ROOB ?](./documentation/cookbook/configuration-custom-js.md)
- [Comment mettre en place un SSO ?](./documentation/cookbook/configuration-sso.md)

## Mettre à jour votre instance RUDI ROOB

Vous avez déjà déployé et configuré mon instance RUDI ROOB avec une version plus ancienne et vous souhaitez la mettre à jour.

Choisissez la procédure à suivre selon votre cas de figure :
  * Le [cas général](./documentation/cookbook/update-instance-general.md), lorsque vous n'avez pas fait de modifications autres que le fichier ``.env``.
  * Le [cas avec des données personnalisées](./documentation/cookbook/update-instance-custom-data.md), lorsque vous avez fait des opérations sur votre instance que vous souhaitez conserver (création d'utilisateur, création de réutilisation, publication de jeu de données, modification d'articles sur Magnolia, etc.).
  * Le [cas avec des modifications de configuration avancées](./documentation/cookbook/update-instance-advanced-config.md), lorsque vous avez modifié des fichiers de configuration.

En fonction des montées de version, des étapes supplémentaires peuvent être nécessaires. Veuillez consulter le tableau ci-dessous pour plus d'informations et dérouler successivement les instructions spécifiques de chaque version si besoin.

| Version | Opération nécessaires                                                        | Notes de version                                                                                                                                   |
|---------|------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------|
| v3.3.4  | Pas d'opération spécifique                                                   | [Notes de version v3.3.4](https://github.com/rudi-platform/rudi-portal/releases/tag/v3.3.4)                                                        |
| v3.3.5  | Pas d'opération spécifique                                                   | [Notes de version v3.3.5](https://github.com/rudi-platform/rudi-portal/releases/tag/v3.3.5)                                                        |
| v3.3.6  | Pas d'opération spécifique                                                   | [Notes de version v3.3.6](https://github.com/rudi-platform/rudi-portal/releases/tag/v3.3.6)                                                        |
| v3.3.7  | Pas d'opération spécifique                                                   | [Notes de version v3.3.7](https://github.com/rudi-platform/rudi-portal/releases/tag/v3.3.7)                                                        |
| v3.3.8  | Pas d'opération spécifique                                                   | [Notes de version v3.3.8](https://github.com/rudi-platform/rudi-portal/releases/tag/v3.3.8)                                                        |
| v3.3.9  | [Opération à effectuer pour la v3.3.9](./documentation/changelogs/v3.3.9.md) | [Notes de version v3.3.9](https://github.com/rudi-platform/rudi-portal/releases/tag/v3.3.9)                                                        |
| v3.3.13  | [Opération à effectuer pour la v3.3.13](./documentation/changelogs/v3.3.13.md) | <pre><ul><li> [Notes de version v3.3.10](https://github.com/rudi-platform/rudi-portal/releases/tag/v3.3.10) </li><li> [Notes de version v3.3.12](https://github.com/rudi-platform/rudi-portal/releases/tag/v3.3.12) </li><li> [Notes de version v3.3.13](https://github.com/rudi-platform/rudi-portal/releases/tag/v3.3.13) </li></ul></pre>|


## L'écosystème Rudi (les autres dépôts de code)

Le portail Rudi n'est qu'une partie de l'écosystème de la plateforme Rudi. Pour l'utiliser pleinement, réferez-vous aux autres dépôts de code de l'organisation:

### [Le Portail Rudi ✨](https://github.com/rudi-platform/rudi-portal)

La partie grand public de la plateforme Rudi.

### Nœud Producteur RUDI 

Un ensemble d'outils pour les producteurs de données comprenant :

#### [Node Manager 👀](https://github.com/rudi-platform/rudi-node-manager)

Gérez les accès et les interactions avec vos données.

#### [Node Storage 💽](https://github.com/rudi-platform/rudi-node-storage)

Stockez et organisez vos données en toute sécurité.

#### [Node Catalog 🗂️](https://github.com/rudi-platform/rudi-node-catalog)
Décrivez et indexez vos jeux de données pour les rendre facilement trouvables.

## Contribuer à Rudi

Nous accueillons et encourageons les contributions de la communauté. Voici comment vous pouvez participer :
- 🛣️ [Feuille de route](https://github.com/orgs/rudi-platform/projects/2)
- 🐞 Pour les bugs :
  - Version "out of the box" : [créez une issue ici](https://github.com/rudi-platform/rudi-out-of-the-box/issues)
  - Composants spécifiques : rendez-vous sur la section "Issues" du dépôt concerné
- ✨ Pour les contributions de code, direction les dépôts des différents composants. Plus d'informations sur les différentes manières de contribuer sur notre page [Contribuer](https://github.com/rudi-platform/.github/blob/main/CONTRIBUTING.md)
- 🗣️ [Participer aux discussions](https://github.com/orgs/rudi-platform/discussions)

