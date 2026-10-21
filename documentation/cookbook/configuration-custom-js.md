# Comment charger un script javascript personnalisé dans mon instance RUDI ROOB ?

_Cas d'usage_ : je souhaite charger automatiquement un script JavaScript personnalisé dans le front-office, par exemple pour ajouter de l'analytique.

## Modifier le fichier de configuration

Pour charger un script JavaScript personnalisé dans le front-office, il faut modifier le fichier `config/konsult/konsult-front-office.json` et ajouter l'URL d'accès au script dans la liste `scripts`.

L'URL peut être absolue ou relative au microservice Konsult. Dans ce dernier cas, le script doit être placé dans le répertoire `config/konsult/scripts/` pour être accessible.

Il est également possible de spécifier quels scripts doivent être rechargés à chaque changement de page (option `reload` à `true`) ou seulement au chargement de la première page (option `reload` à `false`).

Exemples de valeurs :

```json
{
    ...
    "scripts": [
      {
        "url": "https://mon-cdn-externe.com/mon-script-personnalise.js",
        "reload": false
      },
      {
        "url": "/konsult/v1/properties/scripts/mon-script-personnalise.js",
        "reload": true
      }
    ],
    ...
}
```
