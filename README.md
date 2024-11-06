<br>
<p align="center">
  <a href="https://rudi.rennesmetropole.fr/">
  <img src="https://blog.rudi.bzh/wp-content/uploads/2020/11/logo_bleu_orange.svg" width=100px alt="Rudi logo" />  </a>
</p>

<h2 align="center" >Rudi Out of the Box 📦</h3>
<p align="center">La version dockerisée du Portail Rudi permettant de tester le logiciel en local.</p>

<p align="center"><a href="https://rudi.rennesmetropole.fr/">🌐 Instance de Rennes Métropole</a> · <a href="doc.rudi.bzh">📚 Documentation</a> ·  <a href="https://blog.rudi.bzh/">📰 Blog</a><p>

</div>

## Lancer Rudi en local 🖥️

### Avant de commencer 

Pour faire tourner RUDI sur votre machine, vous aurez besoin de :
- [Docker](https://docs.docker.com/get-docker/) - Pour la containerisation
- [Docker Compose](https://docs.docker.com/compose/install/) - Pour tout orchestrer 
- [Git LFS](https://git-lfs.com/) - Pour gérer les grands fichiers

### 1. Récupérez le code
```bash
git clone https://github.com/rudi-plateform/rudi-oob.git
cd rudi-oob
git lfs pull
```

### 2. Configurez votre environnement
Jetez un œil au fichier `.env` :
- La variable `base_dn` définit le nom de votre serveur RUDI (par défaut : `localhost`)
- Vous voulez utiliser un nom personnalisé ? Ajoutez dans votre fichier hosts :
```
<ip> dataverse.<votre_nom> magnolia.<votre_nom> rudi.<votre_nom>
```

### 3. Lancez les services

Une seule commande pour tout démarrer :
```bash
docker compose -f .\docker-compose-magnolia.yml \
               -f .\docker-compose-rudi.yml \
               -f .\docker-compose-dataverse.yml \
               -f .\docker-compose-network.yml \
               --profile "*" up -d
```

### Où trouver quoi ? 🔎
- RUDI vous attend sur `http://rudi.localhost/` (ou l'adresse définie dans votre `.env`)
- Le catalogue Dataverse : `http://dataverse.<votre_nom>`
- Le CMS Magnolia : `http://magnolia.<votre_nom>`
- Les services RUDI : `http://rudi.<votre_nom>/<service>`

### Les commandes utiles

Besoin de tout arrêter  ?
```bash
docker compose -f .\docker-compose-magnolia.yml \
               -f .\docker-compose-rudi.yml \
               -f .\docker-compose-dataverse.yml \
               -f .\docker-compose-network.yml \
               --profile "*" down
```

Envie de tout reconstruire ?
```bash
docker compose -f .\docker-compose-magnolia.yml \
               -f .\docker-compose-rudi.yml \
               -f .\docker-compose-dataverse.yml \
               -f .\docker-compose-network.yml \
               --profile "*" up --build
```

Juste reconstruire les images ?
```bash
docker compose -f .\docker-compose-magnolia.yml \
               -f .\docker-compose-rudi.yml \
               -f .\docker-compose-dataverse.yml \
               -f .\docker-compose-network.yml \
               --profile "*" build
```

### Tests à la carte

Vous pouvez lancer uniquement les services qui vous intéressent grâce à l'option `--profile`. 
<br>

## L'écosystème Rudi (les autres dépôts de code)

Le portail Rudi n'est qu'une partie de l'écosystème de la plateforme Rudi. Pour l'utiliser plainement, réferez vous aux autres dépôts de code de l'organisation:

### [Le Portail Rudi ✨](https://github.com/rudi-platform/rudi-portal)
La partie grand public de la plateforme Rudi.

### Nœud Producteur RUDI 

Un ensemble d'outils pour les producteurs de données comprenant :

#### [Node Manager 👀](https://github.com/rudi-platform/rudi-node-manager)
Gérez les accès et les interactions avec vos données.

#### [Node Storage 💽](https://github.com/rudi-platform/rudi-node-storage)
Stockez et organisez vos données en toute sécurité.

#### [Node Catalog 🗂️](https://github.com/rudi-platform/rudi-node-catalog)
Décrivez et indexez vos jeux de données pour les rendre facilement trouvables.

## Contribuer à Rudi

Nous accueillons et encourageons les contributions de la communauté. Voici comment vous pouvez participer :
- 🛣️ [Feuille de route](https://github.com/orgs/rudi-platform/projects/2)
- 🐞 Pour les bugs :
  - Version "out of the box" : [créez une issue ici](https://github.com/rudi-platform/rudi-out-of-the-box/issues)
  - Composants spécifiques : rendez-vous sur la section "Issues" du dépôt concerné
- ✨ Pour les contributions de code, direction les dépôts des différents composants. Plus d'informations sur les différentes manières de contribuer sur notre page [Contribuer](https://github.com/rudi-platform/.github/blob/main/CONTRIBUTING.md)
- 🗣️ [Participer aux discussions](https://github.com/orgs/rudi-platform/discussions)


