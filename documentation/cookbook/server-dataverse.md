# Comment séparer le déploiement de Dataverse sur un autre serveur ?

_Cas d'usage_ : je souhaite déployer dataverse sur un serveur dédié.

Dans ce document, les dénominations suivantes sont utilisées :
* *ROOB_RUDI* : machine hébergeant les services RUDI (microservices, database, Magnolia, mailhog)
* *ROOB_DATAVERSE* : machine dédiée hébergeant dataverse

## Déployer dataverse sur le serveur *ROOB_DATAVERSE*

La première étape consiste à faire tourner le container de `dataverse` sur le serveur dédié.

Pour cela, sur le serveur *ROOB_DATAVERSE* récupérer le projet ROOB

```bash
git clone https://github.com/rudi-platform/rudi-out-of-the-box.git
cd rudi-out-of-the-box
git lfs pull
chmod -R 777 data
chmod -R 755 config
```

Conserver uniquement l'arborescence nécessaire pour `dataverse` :

```
├── .env
├── config
│   └── dataverse-init
├── data
│   └── dataverse
├── docker-compose-dataverse.yml
├── docker-compose-network.yml
└── image
    └── dataverse
```

Modifier `docker-compose-network.yml` : conserver uniquement les services `reverse-proxy`, `solr`  et `dataverse`.

Modifier le fichier `.env` tel qu'indiqué dans le [README](../../README.md)

Démarrer les services :

```bash
docker compose -f ./docker-compose-dataverse.yml -f ./docker-compose-network.yml up -d
```


Vérifier que l'accès à Dataverse fonctionne depuis la machine hébergeant les services RUDI *ROOB_RUDI* : `http://dataverse.<ROOB_DATAVERSE>`.


> Ajouter l'IP de dataverse dans le fichier hosts de la machine hébergeant les services RUDI si nécessaire.
>    ```
>    <ip> dataverse.<ROOB_DATAVERSE>
>    ```


## Modifier la configuration des microservices sur le serveur *ROOB_RUDI*

Les opérations suivantes sont à faire sur la machine *ROOB_RUDI*.

Modifier la propriété suivante pour les microservices qui utilisent dataverse :

``` properties
dataverse.api.url=http://dataverse.<ROOB_DATAVERSE>/api
```

Les fichiers concernés sont :
* `apigateway.properties`
* `kalim.properties`
* `konsult.properties`
* `projekt.properties`
* `selfdata.properties`
* `strukture.properties`

Supprimer les répertoires et fichiers de dataverse :

```
├── config
│   └── dataverse-init
├── data
│   └── dataverse
├── docker-compose-network.yml
└── image
    └── dataverse
```

Dans le fichier `docker-compose-network.yml` : supprimer les services `reverse-proxy`, `solr`  et `dataverse`.

Relancer les services.