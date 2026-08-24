# Comment passer une instance Roob en production ?

## Prérequis

- Serveur Linux (Ubuntu/Debian recommandé)
- Docker et Docker Compose installés
- Git pour récupérer le code source
- Certificats SSL valides pour votre domaine

## Gestion des volumes persistants

Configurez des volumes Docker persistants pour les données importantes:
- Dataverse
- Magnolia
- RUDI

### Dataverse

Le fichier ``docker-compose-dataverse.yml`` doit être modifié afin de rendre les volumes persistants pour les index Solr et la base de données PostgreSQL.

#### Dataverse - Postgresql

Créer dans le répertoire *rudi-out-of-the-box* un sous-répertoire *./database-data/dataverse*

Copier le contenu du répertoire du conteneur ``/var/lib/postgresql/data/`` dans le répertoire ``./database-data/dataverse``.


> ```bash 
> docker compose cp postgres:/var/lib/postgresql/data/ ./database-data/dataverse
> ```

Exposer le volume des données pour la base de données en modifiant la section ``volumes``:

```
services:
  postgres:
    image: postgres:15.8
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "pg_isready"]
      interval: 30s
      timeout: 30s
      retries: 5
      start_period: 30s
    environment:
      - "LC_ALL=C.UTF-8"
      - "POSTGRES_DB=dataverse"
      - "POSTGRES_USER=dataverse"
      - "POSTGRES_PASSWORD=Rud1R00B-db-dataverse"
      - "POSTGRES_PORT=5432"
    env_file:
      - data/dataverse/.env
    volumes:
      - ./config/dataverse/dataverse-init/:/docker-entrypoint-initdb.d/
      - ./database-data/dataverse:/var/lib/postgresql/data/
    profiles:
      - dataverse
```

Redémarrer le service (option docker compose: up -d)

#### Dataverse - Index SolR

Le volume des index est déjà exposé dans la section *volumes* du service *solr*.

### Magnolia

Le fichier ``docker-compose-magnolia.yml`` doit être modifié afin de rendre les volumes persistants pour les index et la base de données PostgreSQL.

#### Magnolia - Postgresql

Créer dans le répertoire *rudi-out-of-the-box* un sous-répertoire *./database-data/magnolia*

Copier le contenu du répertoire du conteneur ``/var/lib/postgresql/data/`` dans le répertoire ``./database-data/magnolia``.

> ```bash 
> docker compose cp magnolia-database:/var/lib/postgresql/data/ ./database-data/magnolia
> ```

Exposer le volume des données pour la base de données en modifiant la section ``volumes``:

```
services:
  magnolia-database:
    image: postgres:15.8
    expose:
      - 5432
    #image: glregistry.boost.open.global/rennes-metropole/rudi/rudi/magnolia-postgres:rudi-4307-cms
    environment:
      - "POSTGRES_DB=magnolia"
      - "POSTGRES_USER=magnolia"
      - "POSTGRES_PASSWORD=Rud1R00B-db-magnolia"
      - "POSTGRES_PORT=5432"
    healthcheck:
      test: ["CMD", "pg_isready"]
      interval: 30s
      timeout: 30s
      retries: 5
      start_period: 30s
    volumes:
      - ./config/magnolia-data/:/docker-entrypoint-initdb.d/
      - ./database-data/magnolia:/var/lib/postgresql/data
    profiles:
      - magnolia
```

#### Magnolia - Index

Le volume des index est déjà exposé dans la section *volumes* du service *magnolia*.

### Portail

Le fichier ``docker-compose-rudi.yml`` doit être modifié afin de rendre les volumes persistants pour la base de données PostgreSQL.

#### Portail - Postgresql

Créer dans le répertoire *rudi-out-of-the-box* un sous-répertoires *./database-data/rudi*

Copier le contenu du répertoire du conteneur ``/var/lib/postgresql/data/`` dans le répertoire ``./database-data/rudi``.

> ```bash 
> docker compose cp database:/var/lib/postgresql/data/ ./database-data/rudi
> ```

Exposer le volume des données pour la base de données en modifiant la section ``volumes``:

```
services:
  database:
    image: postgres:15.8
    environment:
      - POSTGRES_USER=rudi
      - POSTGRES_PASSWORD=rudi
      - POSTGRES_DB=Rud1R00B-db-rudi
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U $$POSTGRES_USER -d $$POSTGRES_DB -h database"]
      interval: 30s
      timeout: 30s
      retries: 5
      start_period: 500s
    volumes:
      - ./config/rudi-init/:/docker-entrypoint-initdb.d/
      - ./database-data/rudi:/var/lib/postgresql/data
    profiles:
      - portail
```

**Attention :**

- Assurez-vous que les répertoires des volumes persistants ont les bonnes permissions pour éviter des problèmes d'accès.


## Gestion des mots de passe

Afin de pouvoir passer en production, il est nécessaire de modifier les mots de passe :

- Des bases de données
- Des utilisateurs des microservices
- Des utilisateurs Dataverse
- Des utilisateurs Magnolia

### Mot de passe - Base de données

#### Mot de passe - Base de données - Dataverse

Se connecter sur la base de données Dataverse.
Modifier le mot de passe de l'utilisateur *dataverse* 
Modifier le fichier ``docker-compose-dataverse.yml`` et notamment les variables d'environnement suivantes :

- Dans le service ``postgres`` :

>      - "POSTGRES_PASSWORD=Rud1R00B-db-dataverse"

- Dans le service ``dataverse`` :

>      - "DATAVERSE_DB_PASSWORD=Rud1R00B-db-dataverse"

#### Mot de passe - Base de données - Magnolia

Se connecter sur la base de données Magnolia.
Modifier le mot de passe de l'utilisateur *magnolia* 

- Dans le service ``magnolia-database`` :

>      - "POSTGRES_PASSWORD=Rud1R00B-db-magnolia"

- Dans le service ``magnolia`` :

>      - "MAGNOLIA_BDD_PASSWORD=Rud1R00B-db-magnolia"

#### Mot de passe - Base de données - RUDI

Se connecter sur la base de données RUDI.
- Modifier le mot de passe des utilisateurs *rudi*, *acl*, *apigateway*, *kalim*, *konsent*, *kos*, *projekt*, *selfdata*, *strukture*

- Dans le service ``database``, renseigner le nouveau mot de passe de l'utilisateur `rudi` :

>      - POSTGRES_PASSWORD="Rud1R00B-db-rudi"

Editer les fichier ``./config/<nom du micro service>/<nom du micro service>.properties`` et mettre à jour les propriétés ``spring.datasource.password=xxx`` avec les nouveaux mots de passe des utilisateurs concernés.

## Mot de passe - Utilisateurs

### Mot de passe - Utilisateurs - Dataverse

Pour modifier les mots de passe Dataverse, se référer à la documentation [documentation/cookbook/modifier-mot-de-passe-dataverse.md](https://github.com/rudi-platform/rudi-portal/blob/main/documentation/cookbook/modifier-mot-de-passe-dataverse.md)
 
### Mot de passe - Utilisateurs - Magnolia 

Pour modifier les mots de passe Magnolia, se référer à la documentation [documentation/cookbook/modifier-mot-de-passe-magnolia.md](https://github.com/rudi-platform/rudi-portal/blob/main/documentation/cookbook/modifier-mot-de-passe-magnolia.md)

### Mot de passe - Utilisateurs - Portail 

Les mots de passe des utilisateurs RUDI sont stockés dans la base de données Portail dans le schéma ``acl``.

Pour ce faire se référer à ``https://github.com/rudi-platform/rudi-portal/blob/main/documentation/cookbook/modifier-mot-de-passe-base.md``

## Gestion des certificats

## Gestion HTTPS

Afin de passer en production, il est nécessaire de mettre en place un certificats SSL pour la communication avec le portail.

Pour ce faire, se référrer à :

- [Comment mettre en place un certificat SSL pour traefik ?](./treafik-certificat-ssl.md)
- [Comment passer de traefik à Apache ?](./treafik-to-apache.md)

## Gestion des Keystore

Le portail RUDI comporte plusieurs KeyStore :

- Les keystores SSL. 
- Le keystore de chiffrement des consentements
- Le keystore de chiffrement des données personnelles
- Le keystore de chiffrement des clés d'accès aux données
- Le keystore de signature des tokens JWT

### Gestion du keystore JWT

Pour configurer un keystore JWT persisté permettant la signature des tokens JWT, se référer à :

- [Comment générer une clé privée persistée pour les certificats des JWT ?](./configuration-acl-jwt.md)

### Gestion des Keystore - SSL

Ces keystores sont présents dans les répertoires ``./config/<nom du microservice>/``.

Il est nécessaire :

- de modifier le certificat présent dans les keystores en le remplaçant par celui obtenu pour le nom de domaine.
- de mettre à jour les fichiers de propriétés  ``./config/<nom du microservice>/<nom du microservice>.properties``.

> server.ssl.key-store-password=<mot de passe keystore>

> eureka.client.tls.key-password=<mot de passe keystore>

### Gestion du keystore de chiffrement des consentements

Il est nécessaire :

- de modifier le certificat présent dans le keystore ``rudi-konsent.jks`` en le remplaçant par celui obtenu pour le nom de domaine.
- de mettre à jour les fichiers de propriétés  ``./config/konsent/konsent.properties``.

> rudi.pdf.sign.keyStorePassword=<mot de passe consentement>

> rudi.pdf.sign.keyStoreKeyPassword=<mot de passe consentement>

> rudi.consent.validate.sha.salt=<salt>

> rudi.consent.revoke.sha.salt=<salt>

> rudi.treatmentversion.publish.sha.salt=<salt>

### Gestion du keystore des données personnelles

Il est nécessaire :

- de modifier le certificat présent dans le keystore ``rudi-selfdata.jks`` en le remplaçant par celui obtenu pour le nom de domaine.
- de mettre à jour les fichiers de propriétés  ``./config/selfdata/selfdata.properties``.

> rudi.selfdata.matchingdata.keystore.keystore-password=<mot de passe>

### Gestion du keystore des clés d'accès aux données

Il est nécessaire :

- de modifier le certificat présent dans le keystore ``rudi-apigateway.jks`` en le remplaçant par celui obtenu pour le nom de domaine.
- de mettre à jour les fichiers de propriétés  ``./config/apigateway/apigateway.properties``.

> encryption-key.jks.default-key-password=<mot de passe>

## Pour aller plus loin

### Gestion des sauvegardes :

N'oublier pas de mettre en place une politique de sauvegarde pour les bases de données et les index des différents services.

### Surveillance et logs :

N'oublier pas de mettre en place une configuration idoine des logs ainsi qu'une supervision des services.
