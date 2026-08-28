# Comment séparer le déploiement d'un microservice RUDI sur un autre serveur ?

_Cas d'usage_ : je souhaite déployer l'un des microservices de RUDI sur un serveur dédié.
L'exemple suivant utilise le microservice `apigateway`, mais la procédure est similaire pour les autres microservices RUDI.

Dans ce document, les dénominations suivantes sont utilisées :
* *ROOB_RUDI* : machine hébergeant les services RUDI (microservices (sauf apigateway), database, dataverse, Magnolia, mailhog)
* *ROOB_APIGATEWAY* : machine dédiée hébergeant le microservice apigateway

## Déployer le microservice sur le serveur dédié *ROOB_APIGATEWAY*
La première étape consiste à faire tourner le container de `apigateway` sur le serveur dédié.

Pour cela, récupérer le projet ROOB sur le serveur *ROOB_APIGATEWAY*:

```bash
git clone https://github.com/rudi-platform/rudi-out-of-the-box.git
cd rudi-out-of-the-box
git lfs pull
chmod -R 777 data
chmod -R 755 config
```

Conserver uniquement l'arborescence nécessaire pour `apigateway` :

```
├── .env
├── config
│   └── apigateway
├── docker-compose-network.yml
└── docker-compose-rudi.yml
```

Modifier `docker-compose-network.yml` : conserver uniquement les services `reverse-proxy` et `apigateway`.

Modifier `docker-compose-rudi.yml` : conserver uniquement le service `apigateway`.

Modifier le fichier `.env` tel qu'indiqué dans le [README](../../README.md)

Modifier la configuration de `apigateway` dans le fichier `./config/apigateway/apigateway.properties` pour que la valeur de la propriété `eureka.instance.hostname` corresponde au host de la machine hébergeant le service `registry` (*ROOB_RUDI*). 

``` properties
eureka.instance.hostname=<ip_ou_hostname_*ROOB_RUDI*>
```

Modifier le fichier `apigateway.properties` : changer la valeur de la propriété suivante pour pointer sur le serveur de base de données RUDI:

``` properties
spring.datasource.url=jdbc:postgresql://<ip_ou_hostname_*ROOB_RUDI*>:5432/rudi
```

Démarrer les services :

```bash
docker compose -f ./docker-compose-rudi.yml -f ./docker-compose-network.yml up -d
```

## Modifier la configuration des autres serveurs

Supprimer les répertoires et fichiers de configuration et de données relatifs au microservice `apigateway` sur la machine *ROOB_RUDI* :

```
└── config
    └── apigateway
```

Arrêter le service `apigateway` puis 
* Modifier `docker-compose-network.yml` : supprimer le service `apigateway`.
* Modifier `docker-compose-rudi.yml` : supprimer le service `apigateway`.

Redémarrer les services.
