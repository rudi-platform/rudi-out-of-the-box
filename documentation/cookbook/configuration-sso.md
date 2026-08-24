# Comment mettre en place un SSO ?

_Cas d'usage_ : je souhaite mettre en place un SSO pour mon instance RUDI ROOB afin de permettre à mes utilisateurs de se connecter avec leurs identifiants existants.

## Pré-requis

Disposer d'un fournisseur d'identité compatible OpenID Connect (OIDC) pour gérer l'authentification des utilisateurs.

## Configuration du portail pour la connexion au fournisseur d'identité

Dans le fichier `config/acl/acl.properties`, ajouter une propriété permettant d'indiquer le fichier déclarant les différents services d'identité :

```properties
rudi.oauth2.authenticator.configuration=/etc/rudi/config/acl/oauth2-authenticator.json
```

Créer le fichier `config/acl/oauth2-authenticator.json` pour surcharger la configuration par défaut du portail RUDI pour le SSO. Ce fichier doit contenir un tableau JSON avec les configurations pour chaque fournisseur d'identité. 

L'exemple de configuration suivant permet de configurer le portail RUDI comme son propre fournisseur d'identité :

```json
[
	{
		"name": "rudi",
		"label": "OAuth2 Rudi",
		"description": "Internal OAuth2 authenticator",
		"serverUrl": "${localServerUrl}",
		"clientId": "66044585-0bbc-49fd-837e-ce6f22d8824b",
		"clientSecret": "9d9d0b6a-310a-46c8-9fbb-402d41e4a93a",
		"authorizationGrantType": "client_credentials",
		"scope": "read,write"
	}
]
```

Le fichier peut contenir plusieurs configurations pour différents fournisseurs d'identité, par exemple pour Github, FranceConnect ou LemonLDAP.

## Structure du fichier oauth2-authentifcator.json

Le fichier `oauth2-authenticator-advanced.json` (ou `oauth2-authenticator.json`) contient une liste de configurations d'authentificateurs OAuth2. Chaque entrée décrit un fournisseur d'identité externe ou interne.


### Champs racine d'un authentificateur

| Champ | Type | Valeur par défaut | Rôle |
|---|---|---|---|
| `name` | `string` | — | Identifiant technique unique de l'authentificateur (utilisé comme clé de registration Spring). |
| `label` | `string` | — | Libellé affiché à l'utilisateur dans l'interface. |
| `description` | `string` | — | Description textuelle de l'authentificateur. |
| `serverUrl` | `string` | — | URL de base du serveur d'identité. Sert de valeur pour `${serverUrl}` dans les autres champs. Accepte `${localServerUrl}` pour pointer vers le serveur RUDI local. |
| `redirectUrl` | `string` | `${serverUrl}/login/oauth2/code/` | URI de redirection OAuth2 après authentification réussie. |
| `clientId` | `string` | — | Identifiant client enregistré auprès du fournisseur OAuth2. |
| `clientSecret` | `string` | — | Secret client partagé avec le fournisseur OAuth2. |
| `clientAuthenticationMethod` | `string` | `client_secret_basic` (Spring) | Méthode d'authentification du client auprès du token endpoint. Ex. : `client_secret_post`, `client_secret_basic`. |
| `requireProofKey` | `boolean` | `false` | Active le PKCE (Proof Key for Code Exchange) pour sécuriser le flux `authorization_code`. |
| `scope` | `string` | — | Liste de scopes OAuth2 séparés par des virgules. Ex. : `openid,profile,email`. |
| `authorizationGrantType` | `enum` | `authorization_code` | Type de flux OAuth2. Valeurs : `authorization_code`, `client_credentials`, `password`, `refresh_token`. |
| `provider` | `object` | voir section [provider](#objet-provider) | Configuration des endpoints du fournisseur d'identité. |
| `viewSettings` | `object` | voir section [viewSettings](#objet-viewsettings) | Paramètres d'affichage dans l'interface utilisateur. |


### Objet `provider`

| Champ | Type | Valeur par défaut | Rôle |
|---|---|---|---|
| `authorizationUri` | `string` | `${serverUrl}/oauth2/authorize` | URL d'autorisation où l'utilisateur est redirigé pour s'authentifier. |
| `tokenUri` | `string` | `${serverUrl}/oauth2/token` | URL d'échange du code d'autorisation contre un access token. |
| `userInfoUri` | `string` | `${serverUrl}/oauth2/userinfo` | URL pour récupérer les informations de l'utilisateur connecté. |
| `userInfoAuthenticationMethod` | `string` | `header` (Spring) | Méthode d'envoi du token lors de l'appel à `userInfoUri`. Ex. : `header`, `query`, `form`. |
| `userNameAttribute` | `string` | `sub` | Nom du claim JWT ou attribut userinfo utilisé comme identifiant principal de l'utilisateur. |
| `jwkSetUri` | `string` | `${serverUrl}/oauth2/jwks` | URL du JWKS (JSON Web Key Set) pour la vérification des tokens JWT. |
| `issuerUri` | `string` | *(non défini)* | URI de l'émetteur JWT (utilisé pour la découverte automatique OpenID Connect). |
| `logoutUri` | `string` | `${serverUrl}/logout` | URL de déconnexion côté fournisseur d'identité. |
| `tokenManagement` | `enum` | `IF_POSSIBLE_PROVIDER` | Stratégie de gestion du token après authentification. Valeurs : `ALWAYS_PROVIDER`, `ALWAYS_RUDI`, `IF_POSSIBLE_PROVIDER`. |
| `roleConvertExpression` | `string` | `ROLE_(.*)` | Expression régulière pour convertir les rôles du fournisseur en rôles RUDI. Le groupe capturant `(.*)` extrait le nom du rôle. |
| `attributeMappings` | `array` | — | Liste de correspondances entre attributs OAuth2 et attributs utilisateur RUDI. Voir section [attributeMappings](#tableau-attributemappings). |
| `additionalParameters` | `object` | — | Paramètres supplémentaires à envoyer au serveur d'autorisation. Ex. : `{ "acr_values": "eidas1" }` pour FranceConnect. |

### Variable `${serverUrl}`

Les variables suivantes sont connues du système et peuvent être utilisées dans le fichier :

- `${serverUrl}` est remplacée à l'exécution par la valeur du champ `serverUrl` de l'authentificateur. 
- `${localServerUrl}` est remplacé par l'URL de base du serveur RUDI local, déduite de la propriété `module.oauth2.check-token-uri`.
- state: un état généré aléatoirement (souvent utilisé dans `logoutUri`)
- token : le token produit par le serveur d'identité (souvent utilisé dans `logoutUri`)

### Tableau `provider.attributeMappings`

Chaque entrée mappe un attribut renvoyé par le fournisseur OAuth2 vers un champ utilisateur RUDI.

| Champ | Type | Valeur par défaut | Rôle |
|---|---|---|---|
| `userAttribute` | `enum` | — | Attribut cible côté RUDI. Valeurs : `LASTNAME`, `FIRSTNAME`, `EMAIL`. |
| `oauth2Attribute` | `string` | — | Nom du claim ou attribut renvoyé par le `userInfoUri` du fournisseur. Ex. : `email`, `family_name`, `login`. |

---

### Objet `viewSettings`

| Champ | Type | Valeur par défaut | Rôle |
|---|---|---|---|
| `isolated` | `boolean` | `false` | Si `true`, l'authentificateur est affiché dans un bloc séparé dans l'interface (ex. : FranceConnect). |
| `cssClass` | `string` | — | Classe CSS appliquée au bouton de connexion dans l'interface. |
| `iconUrl` | `string` | — | URL ou chemin classpath de l'icône du bouton (ex. : `classpath:/authenticators/oauth2-github.png`). Exposée publiquement via `/acl/v1/oauth2-authenticators/icons/{name}@icon`. |
| `hoverIconUrl` | `string` | — | URL ou chemin classpath de l'icône au survol. Exposée via `/acl/v1/oauth2-authenticators/icons/{name}@hover_icon`. |
| `links` | `array` | — | Liste de liens affichés sous le bouton de connexion (ex. : aide, CGU). Chaque lien contient `url` et `label`. |

---

### Valeurs par défaut appliquées automatiquement

Les valeurs suivantes sont injectées par `OAuth2AuthenticatorHelper` si elles sont absentes de la configuration :

| Champ | Valeur injectée |
|---|---|
| `authorizationGrantType` | `authorization_code` |
| `redirectUrl` | `${serverUrl}/login/oauth2/code/` |
| `provider.tokenManagement` | `IF_POSSIBLE_PROVIDER` |
| `provider.authorizationUri` | `${serverUrl}/oauth2/authorize` |
| `provider.tokenUri` | `${serverUrl}/oauth2/token` |
| `provider.userInfoUri` | `${serverUrl}/oauth2/userinfo` |
| `provider.jwkSetUri` | `${serverUrl}/oauth2/jwks` |
| `provider.logoutUri` | `${serverUrl}/logout` |
| `provider.userNameAttribute` | `sub` |
| `provider.roleConvertExpression` | `ROLE_(.*)` |


## Exemple de configuration pour Github

Par défaut, les logos Github sont fournis dans l'image rudiplatform/rudi-microservice-acl, mais il est possible de les remplacer par vos propres logos en modifiant les propriétés `iconUrl` et `hoverIconUrl` dans le fichier `config/acl/oauth2-authenticator.json`.

```json
[
	{
		"name": "rudigithub",
		"label": "OAuth2 github",
		"description": "External OAuth2 authenticator for github",
		"viewSettings": {
			"cssClass": "github",
			"iconUrl": "classpath:/authenticators/oauth2-github.png"
		},
		"serverUrl": "https://github.com",
		"redirectUrl": "https://rudi.<base_dn>/login/oauth2/code/",
		"clientId": "<votre_client_id>",
		"clientSecret": "<votre_client_secret>",
		"authorizationGrantType": "authorization_code",
		"scope": "read,write",
		"provider": {
			"authorizationUri": "${serverUrl}/login/oauth/authorize",
			"tokenUri": "${serverUrl}/login/oauth/access_token",
			"userInfoUri": "https://api.github.com/user",
			"jwkSetUri": "${serverUrl}/login/oauth/jwks",
			"userNameAttribute": "login",
			"attributeMappings": [
				{
					"userAttribute": "EMAIL",
					"oauth2Attribute": "email"
				},
				{
					"userAttribute": "LASTNAME",
					"oauth2Attribute": "login"
				},
				{
					"userAttribute": "FIRSTNAME",
					"oauth2Attribute": "name"
				}
			],
			"roleConvertExpression": "OAUTH2_*(.*)"
		}
	}
]
```

## Exemple de configuration pour FranceConnect

Par défaut, les logos FranceConnect sont fournis dans l'image rudiplatform/rudi-microservice-acl, mais il est possible de les remplacer par vos propres logos en modifiant les propriétés `iconUrl` et `hoverIconUrl` dans le fichier `config/acl/oauth2-authenticator.json`.

```json
[ {
		"name": "rudifranceconnect",
		"label": "Se connecter avec FranceConnect",
		"description": "FranceConnect est la solution proposée par l'État, pour sécuriser et simplifier la connexion à vos services en ligne",
		"viewSettings": {
			"isolated": true,
			"cssClass": "franceconnect",
			"iconUrl": "classpath:/authenticators/franceconnect-btn-principal.svg",
			"hoverIconUrl": "classpath:/authenticators/franceconnect-btn-principal-hover.svg",
			"links": [
				{
					"url": " https://franceconnect.gouv.fr/",
					"label": "Qu'est ce que FranceConnect ?"
				}
			]
		},
		"serverUrl": "https://fcp-low.sbx.dev-franceconnect.fr/api/v2",
		"redirectUrl": "https://rudi.<base_dn>/login/oauth2/code/",
		"clientId": "<votre_client_id>",
		"clientSecret": "<votre_client_secret>",
		"authorizationGrantType": "authorization_code",
        "clientAuthenticationMethod": "client_secret_post",
		"scope": "openid,given_name,family_name,email",
		"provider": {
			"authorizationUri": "${serverUrl}/authorize",
			"tokenUri": "${serverUrl}/token",
			"userInfoUri": "${serverUrl}/userinfo",
			"jwkSetUri": "${serverUrl}/jwks",
            "issuerUri": "${serverUrl}",
            "logoutUri": "${serverUrl}/session/end?post_logout_redirect_uri=https://rudi.<base_dn>&state=${state}&id_token_hint=${token}",
			"userNameAttribute": "sub",
			"attributeMappings": [
				{
					"userAttribute": "EMAIL",
					"oauth2Attribute": "email"
				},
				{
					"userAttribute": "LASTNAME",
					"oauth2Attribute": "family_name"
				},
				{
					"userAttribute": "FIRSTNAME",
					"oauth2Attribute": "given_name"
				}
			],
			"additionalParameters": {
                                "acr_values": "eidas1"
                        }
		}
	}
]
```
**Remarques :**

- il est nécessaire de définir correctement le `serveurUrl` afin d'utiliser l'environnement de production ou un des sandbox.

## Exemple de configuration pour LemonLDAP

Par défaut, les logos LemonLDAP::NG sont fournis dans l'image rudiplatform/rudi-microservice-acl, mais il est possible de les remplacer par vos propres logos en modifiant les propriétés `iconUrl` et `hoverIconUrl` dans le fichier `config/acl/oauth2-authenticator.json`.

```json
[
    
	{
		"name": "lemon",
		"label": "OAuth2 LemonLDAP::NG",
		"description": "External OAuth2 authenticator for LemonLDAP::NG",
		"viewSettings": {
			"iconUrl": "classpath:/authenticators/oauth2-lemon.png"
        },
		"serverUrl": "https://<url de votre fournisseur d'identité>",
		"redirectUrl": "https://rudi.<base_dn>/login/oauth2/code/",
		"clientId": "<votre_client_id>",
		"clientSecret": "<votre_client_secret>",
		"authorizationGrantType": "authorization_code",
        "clientAuthenticationMethod": "client_secret_post",
		"scope": "openid,profile,email,rudi_profile",
		"provider": {
			"authorizationUri": "${serverUrl}/oauth2/authorize",
			"tokenUri": "${serverUrl}/oauth2/token",
			"userInfoUri": "${serverUrl}/oauth2/userinfo",
			"jwkSetUri": "${serverUrl}/oauth2/jwks",
            "logoutUri": "${serverUrl}/?logout=1&post_logout_redirect_uri=https://rudi.<base_dn>",
			"userNameAttribute": "sub"
		}
	}
]
```
