# Comment générer une clé privée persisted pour les certificats des JWT ?

_Cas d'usage_ : je souhaite utiliser un certificat persisté pour signer les tokens JWT, plutôt qu'une chaîne aléatoire générée à chaque démarrage du service.

## Contexte et intérêt

Par défaut, le service ACL génère une clé aléatoire à chaque démarrage pour signer les tokens JWT. Cela pose plusieurs problèmes :

* Impossibilité d'utiliser les tokens entre plusieurs redémarrages
* Manque de transparence et de contrôle sur la signature des tokens

La solution est de générer une clé privée unique persistée dans un keystore dédiée et de configurer le microservice ACL afin qu'il utilise cette clé pour la signature des tokens.

## Prérequis

* OpenSSL installé et disponible dans le PATH
* Java 21 installé et disponible dans le PATH (pour l'outil `keytool`)
* Accès au répertoire `config/acl/`
* Un mot de passe pour sécuriser le keystore

## Générer la paire de clés RSA

Depuis le répertoire racine du projet `rudi-out-of-the-box`, exécuter les commandes suivantes :

Générer la clé privée RSA de 2048 bits :

```bash
openssl genpkey -algorithm RSA -out ./config/acl/rudi-acl-jwt-private-key.pem -pkeyopt rsa_keygen_bits:2048
```

Générer le certificat public à partir de la clé privée :

```bash
openssl rsa -in ./config/acl/rudi-acl-jwt-private-key.pem -pubout -out ./config/acl/rudi-acl-jwt-public-key.pem
```

**Note :** Ces fichiers contiennent respectivement la clé privée et le certificat public. Ils doivent être sauvegardés de manière sécurisée.

## Convertir en format PKCS12

Convertir la paire clé privée / certificat public en format PKCS12 intermédiaire :

```bash
openssl pkcs12 -export \
  -in ./config/acl/rudi-acl-jwt-public-key.pem \
  -inkey ./config/acl/rudi-acl-jwt-private-key.pem \
  -name "rudi-jwt" \
  -out ./config/acl/rudi-jwt.p12 \
  -passout pass:<mot_de_passe_keystore>
```

Remplacer `<mot_de_passe_keystore>` par le mot de passe souhaité.

## Importer dans un keystore Java (JKS)

Convertir le fichier PKCS12 en keystore Java (JKS) :

```bash
keytool -importkeystore \
  -deststorepass <mot_de_passe_keystore> \
  -destkeystore ./config/acl/rudi.jwt.jks \
  -srckeystore ./config/acl/rudi-jwt.p12 \
  -srcstoretype PKCS12 \
  -srcstorepass <mot_de_passe_keystore> \
  -noprompt
```

Remplacer `<mot_de_passe_keystore>` par le mot de passe utilisé précédemment.

**Résultat :** Un fichier `./config/acl/rudi.jwt.jks` contenant la clé privée.

## Nettoyer les fichiers intermédiaires

Supprimer les fichiers PKCS12 qui ne sont plus nécessaires :

```bash
rm ./config/acl/rudi-jwt.p12
```

Optionnellement, vous pouvez aussi supprimer les fichiers PEM si vous n'en avez plus besoin :

```bash
rm ./config/acl/rudi-acl-jwt-public-key.pem ./config/acl/rudi-acl-jwt-private-key.pem
```

## Configurer le service ACL

Modifier le fichier `config/acl/acl.properties` pour pointer vers le keystore créé :

```properties
# Keystore JWT
rudi.jwt.keystore.path=./config/acl/rudi.jwt.jks
rudi.jwt.keystore.password=<mot_de_passe_keystore>
rudi.jwt.keystore.alias=rudi-jwt
rudi.jwt.keystore.key.password=<mot_de_passe_keystore>
```

Remplacer `<mot_de_passe_keystore>` par le mot de passe utilisé lors de la création du keystore.

## Redémarrer le service

Redémarrer le conteneur ACL pour que la configuration soit prise en compte :

```bash
docker compose -f ./docker-compose-rudi.yml up -d acl
```

Les tokens JWT signés par le service ACL utiliseront désormais la clé privée présente dans le keystore `rudi.jwt.jks`. 
