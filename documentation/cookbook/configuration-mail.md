# Comment configurer l'envoi de mails ?

_Cas d'usage_ : je veux remplacer l'utilisation du simulateur de serveur de mail `mailhog` par un serveur de mail existant.

## Prérequis
Afin de configurer le serveur de mail utilisé par ROOB, vous devez au préalable disposer d'un serveur de mail fonctionnel et connaitre ses informations de connexion :

* Serveur
* Port
* Protocol
* Informations d'authentification (utilisateur, mot de passe)
* Adresse "from" à utiliser
* Utilisation du StartTLS
* Utilisation du debug

## Modifier les fichiers de propriétés pour chaque microservice concerné

Les microservices suivants utilisent l'envoi de mail :
* ACL
* Kalim
* Projekt
* Selfdata
* Strukture

Pour chaque microservice, modifier le fichier de configuration associé `config/<nomDuMicroservice>/<nomDuMicroservice>.properties`.

Les propriétés concernés sont :

| Nom de la propriété | Description | Exemple de valeur | Valeur par défaut |
|---------------------|-------------|-------------------|-------------------|
| mail.transport.protocol | Protocol | smtp | smtp |
| mail.smtp.host | Hôte du serveur de mail | mailhog | |
| mail.smtp.port | Port du serveur de mail | 1025 | 25 |
| mail.smtp.auth | Utilisation d'une authentification | true | false |
| mail.smtp.user | Nom d'utilisateur pour l'authentification (utilisé si mail.smtp.auth=true) | user@example.com | |
| mail.smtp.password | Mot de passe pour l'authentification (utilisé si mail.smtp.auth=true) | motdepasse | |
| mail.smtp.starttls.enable | Utilisation du StartTLS | true | false |
| mail.from | Adresse expéditeur des emails | nepasrepondre@rudi.localhost | |
| mail.debug | Activation du mode debug | false | false |

Pour que la configuration soit prise en compte, redémarrer les microservices concernés.

## Désactiver mailhog

Arrêter le container de mailhog :

```bash
docker compose -f ./docker-compose-rudi.yml --profile "*" down mailhog
```

Dans le fichier `docker-compose-rudi.yml`, supprimer la section concernant le service `mailhog`.