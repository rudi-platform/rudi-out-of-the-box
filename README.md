# **rudi-plateform/rudi-oob**

Bienvenue dans le projet **rudi-plateform/rudi-oob** ! Ceci est une version de lancement rapide pour tester et adopter [rudi-portal](https://github.com/rudi-platform/rudi-portal) dans un environnement local. Cette implémentation __NE DOIT PAS__ être utilisé en l'état en production (Il convient de changer et adapter la configuration notamment les mots de passe). 

## Table des matières
2. [Prérequis](#prérequis)
4. [Utilisation](#utilisation)
5. [Structure du projet](#structure-du-projet)
6. [Tests](#tests)
7. [Contribuer](#contribuer)
8. [Projets liés](#projets-liés)
9. [Licence](#licence)

---

## Prérequis

Avant de commencer, assurez-vous d'avoir installé les éléments suivants sur votre machine :
- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)
- [Git LFS](https://git-lfs.com/)


## Utilisation

### Récupération des sources

Clonez ce dépôt et accédez au répertoire du projet :

```
git clone https://github.com/rudi-plateform/rudi-oob.git
cd rudi-oob
git lfs pull
```

#### 1. Renseignez le fichier `.env`

Consultez et modifiez les variables d'environnement si nécessaire dans le fichier `.env`.

**Focus :**
La variable *base_dn* permet de préciser le nom du serveur Rudi.
La valeur par défaut est *localhost* mais il est possible d'indiquer un nom de machine ou un nom de domaine.
Si l'on précise un nom de machine, il est souvent nécessaire de déclarer dans votre fichier "hosts" quelque windows chose de la forme:

```
adresse_ip dataverse.nom_de_domaine magnolia.nom_de_domaine rudi.nom_de_domaine
```

#### 2. Lancer les services Docker

Pour démarrer les services définis dans les `docker-compose.yml`, exécutez :

```
docker compose -f .\docker-compose-magnolia.yml -f .\docker-compose-rudi.yml -f .\docker-compose-dataverse.yml -f .\docker-compose-network.yml --profile "*" up -d
```

Cette commande démarrera les conteneurs en arrière-plan.

Une fois les conteneurs en cours d'exécution, accédez à l'application sur [http://rudi.localhost/](http://rudi.localhost/) (peux varier en fonction de ce que contient le fichier `.env`).

Il est possible d'accéder :

- Au catalogue **Dataverse** sur *http://dataverse.xxxxx*


#### Arrêter les services
Pour arrêter les services, exécutez :

```
docker-compose -f .\docker-compose-magnolia.yml -f .\docker-compose-rudi.yml -f .\docker-compose-dataverse.yml -f .\docker-compose-network.yml --profile "*"  down
```

#### Recréer les conteneurs (si nécessaire)

```
docker-compose -f .\docker-compose-magnolia.yml -f .\docker-compose-rudi.yml -f .\docker-compose-dataverse.yml -f .\docker-compose-network.yml --profile "*" up --build
```

#### Construire uniquement les images

```
docker-compose -f .\docker-compose-magnolia.yml -f .\docker-compose-rudi.yml -f .\docker-compose-dataverse.yml -f .\docker-compose-network.yml --profile "*" build
```

## Structure du projet

Voici un aperçu de la structure des fichiers du projet :

```
├── config/ : contient les données de configuration et d'initialisation __en lecture seul__ des différents containers.
├── data/ : Donnée en lecture écriture nécessaire au bon fonctionnement. A terme, devrait contenir seulement une strucutre de dossier vide.
├── image/ : Donnée pour construire certaine image "à la volée" depuis des images publiques.
└── .env                  # Exemple de fichier d'environnement
```

## Tests

Pour facilité les tests, il est possible de lancer partiellement des grappes de services grace au tag. Utilise l'option --profile dans le lancement des commandes docker pour lancer uniquement les services voulus.

## Contribuer

Merci de vouloir contribuer ! Consultez le fichier [CONTRIBUTING.md](./CONTRIBUTING.md) pour plus d'informations.

## Projets liés

Ce projet est lié à [rudi-plateform/rudi-portail](https://github.com/rudi-platform/rudi-portal). Veuillez consulter ce projet pour en savoir plus sur l'intégration ou les dépendances partagées.

## Licence

Ce projet est sous licence [EUPL 1.2]. Voir le fichier [Licence](./LICENSE) pour plus de détails.
