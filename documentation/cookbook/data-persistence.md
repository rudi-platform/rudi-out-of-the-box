# Comment faire persister mes données (RUDI, Dataverse, Magnolia) ?

_Cas d'usage_ : lorsque je fais des opérations sur mon environnement ROOB, je veux qu'elles persistent même si je supprime les containers de ROOB.

## Services concernés

Les données sont présentes dans les bases de données suivantes :

* RUDI (service `database`)
* Dataverse (service `dataverse-database`)
* Magnolia (service `magnolia-database`)

Les données initiales sont issues des scripts d'initialisation dans les répertoires `config/rudi-init/`, `config/dataverse-init` et `config/magnolia-init`. 

> Attention : l'externalisation des données peut avoir des impacts sur le bon fonctionnement de l'application en cas de montée de version.

La procédure suivante indique comment persister les données à l'aide d'un montage.

## Prérequis

Les services des bases de données à persister doivent déjà avoir été lancés avant de faire les opérations suivantes.

## Création des répertoires pour les volumes

Pour chacun des services de base de données pour lesquels vous souhaitez persister les données, créer un répertoire `database-data/<module>`.

Par exemple : 

```bash
mkdir -p database-data/rudi 
mkdir -p database-data/dataverse 
mkdir -p database-data/magnolia
```

## Copie des données déjà présentes

Copier le contenu du répertoire des conteneurs ``/var/lib/postgresql/data/`` dans le répertoire ``./database-data/<module>``.

> ```bash 
> docker compose -f ./docker-compose-<module>.yml --profile "*" cp <module>-database:/var/lib/postgresql/data/ ./database-data/<module>
> ```

Exemple :
> ```bash 
> docker compose -f ./docker-compose-rudi.yml --profile "*" cp database:/var/lib/postgresql/data/ ./database-data/rudi
> docker compose -f ./docker-compose-magnolia.yml --profile "*" cp magnolia-database:/var/lib/postgresql/data/ ./database-data/magnolia
> docker compose -f ./docker-compose-dataverse.yml --profile "*" cp dataverse-database:/var/lib/postgresql/data/ ./database-data/dataverse
> ```

## Modification de la configuration docker-compose

Pour chaque service de base de données concerné, modifier la sous-section `volumes` du service dans le fichier `docker-compose-<module>.yml` (en remplaçant `<module>` par le module concerné) :

1. Supprimer ou commenter la ligne de chargement des données préconfigurées dans le service de base de données du module :

```docker
services:
  database:
    ...
    volumes:
      #- ./config/<module>-init/:/docker-entrypoint-initdb.d/
```

2. Ajouter une ligne de montage suivante dans la section volumes, en remplaçant `<module>` par le module concerné :

```docker
services:
  database:
    ...
    volumes:
      - ./database-data/<module>:/var/lib/postgresql/data
```

Avec l'exemple de noms de répertoire ci-dessus, cela donne :
* Pour les données de Dataverse, dans `docker-compose-dataverse.yml` :

```docker
services:
  dataverse-database:
    ...
    volumes:
      #- ./config/dataverse-init/:/docker-entrypoint-initdb.d/
      - ./database-data/dataverse:/var/lib/postgresql/data
```

* Pour les données de Magnolia, dans `docker-compose-magnolia.yml` :

```docker
services:
  magnolia-database:
    ...
    volumes:
      #- ./config/magnolia-init/:/docker-entrypoint-initdb.d/
      - ./database-data/magnolia:/var/lib/postgresql/data
```

* Pour les données de Rudi, dans `docker-compose-rudi.yml` :

```docker
services:
  database:
    ...
    volumes:
      #- ./config/rudi-init/:/docker-entrypoint-initdb.d/
      - ./database-data/rudi:/var/lib/postgresql/data
```

## Prise en compte de la modification

Redémarrer tous les services.

Vos prochaines opérations seront ainsi persistées dans les répertoires créés.