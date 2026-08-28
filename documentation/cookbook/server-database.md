# Comment utiliser un serveur de base de données séparé ?

_Cas d'usage_ : je souhaite utiliser un serveur de base de données PostgreSQL dédié pour héberger la base de données RUDI.

Dans ce document, les dénominations suivantes sont utilisées :
* *ROOB_RUDI* : machine hébergeant les services RUDI (microservices, dataverse, Magnolia, mailhog)
* *ROOB_BDD* : machine dédiée hébergeant la base de données PostgreSQL

## Déployer le serveur de base de données *ROOB_BDD*

La première étape consiste à faire tourner un container PostgreSQL sur le serveur dédié *ROOB_BDD*.

Pour cela, sur le serveur *ROOB_BDD*, récupérer le projet ROOB

```bash
git clone https://github.com/rudi-platform/rudi-out-of-the-box.git
cd rudi-out-of-the-box
git lfs pull
chmod -R 777 data
chmod -R 755 config
```

Conserver uniquement l'arborescence nécessaire pour les bases de données :

```
├── .env
└── config
    └── rudi-init
```

Créer un fichier `docker-compose-database.yml` avec le contenu suivant :

```yaml
---
name: rudiplatform

services:
  database:
    image: postgis/postgis:15-master
    restart: unless-stopped
    ports:
      - 35432:5432
    environment:
      - POSTGRES_USER=rudi
      - POSTGRES_PASSWORD=Rud1R00B-db-rudi
      - POSTGRES_DB=rudi
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U $$POSTGRES_USER -d $$POSTGRES_DB -h database"]
      interval: 30s
      timeout: 30s
      retries: 5
      start_period: 500s
    volumes:
      - ./config/rudi-init/:/docker-entrypoint-initdb.d/
```

En complément, vous pouvez persister les données de la base de données en suivant et adaptant la procédure décrite dans le [cookbook dédié à la persistence des données](./data-persistence.md).

Démarrer les services :

```bash
docker compose -f ./docker-compose-database.yml up -d
```

## Modifier la configuration des services RUDI sur le serveur *ROOB_RUDI*

Les opérations suivantes sont à faire sur la machine hébergeant les services RUDI *ROOB_RUDI*.

Modifier la propriété suivante pour les microservices qui utilisent la base de données RUDI :

``` properties
spring.datasource.url=jdbc:postgresql://<ip_ou_hostname_ROOB_BDD>:5432/rudi
```

Les fichiers concernés sont :
* `acl.properties`
* `apigateway.properties`
* `kalim.properties`
* `konsent.properties`
* `kos.properties`
* `projekt.properties`    
* `selfdata.properties`
* `strukture.properties`

Supprimer les répertoires et fichiers de la base de données RUDI :

```
└── config
    └── rudi-init
```

Arrêter le service `database` puis supprimer la section `database` dans le fichier `docker-compose-rudi.yml`.

Redémarrer les services RUDI.
