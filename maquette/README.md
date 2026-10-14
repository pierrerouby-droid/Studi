# L'Archipel des Nombres

Appli de mathématiques pour un enfant de CE2, pensée pour l'iPhone (au doigt ou au clavier).
`index.html` + le dossier `assets/` (illustrations générées, en WebP). On l'ouvre dans un navigateur, sans installation.

## Version 2 (direction B premium)

- **Carte du monde** peinte : océan animé, lagons, six îles, brouillard sur les îles à découvrir, Kraken en ombre.
- **Marée du jour** : un seul bouton lance trois escales choisies selon ses points faibles (environ 5 minutes), puis retour au port.
- **Chaque île** a une route de 10 niveaux : coffre au niveau 5 (nouvel équipier), boss au niveau 10.
- **Combat naval** pour les tables : boulets, explosions, barre de vie du Requin Noir ou du Kraken.
- **Récompenses** : doublons, coffre à ouvrir, équipiers avec pouvoirs (indice, relance, double butin), surnoms, avis de recherche.
- **Espace parents** : maintenir la roue crantée 2 secondes.

## Version 0.3 bêta (octobre 2026)

- **Chaque île a son décor et son boss** : Kraken des Tables, Crabe Gardien, Golem des Blocs, Serpent Mesureur, Marchand Fantôme, Chef Pieuvre. Les boss ont une barre de vie.
- **Le navire grandit** : sloop au départ, brigantin à 5 victoires, galion à 15. Le Requin Noir s'abîme puis coule.
- **Dix équipiers** gagnés dans les coffres et contre les boss, chacun avec un petit pouvoir (combo, seconde chance, étoile bonus, prime de boss…).
- **Retour au port** avec un vrai décor de fin de session.
- **Espace parents pour la bêta** : formulaire d'avis (envoyé par le menu de partage du téléphone, rien n'est transmis automatiquement), code de sauvegarde et de restauration, guide pour les parents (`aide.html`), numéro de version.
- **Installation sur l'écran d'accueil** : icône, fichier `manifest.webmanifest`, conseil affiché aux parents sur iPhone.

### Mettre en ligne

Ce dossier est le site complet : on le dépose tel quel sur un hébergeur de pages statiques (par exemple Netlify Drop). Les fichiers de travail du design sont dans `design/`, à la racine du dépôt, et ne sont pas mis en ligne.

La suite de ce document décrit la première maquette (version 1).

## Principe

- Une carte avec des îles. Chaque île est un mini-jeu qui travaille une notion du programme de CE2 (BO n° 41 du 31 octobre 2024).
- Une escale = 6 questions, environ une minute. Une session est limitée à 5 minutes, réglable dans l'espace parents.
- La difficulté s'adapte toute seule : 5 ou 6 bonnes réponses font monter d'un niveau (sur 5), 2 ou moins le font redescendre.
- Une erreur n'est jamais punie. L'enfant voit la bonne réponse et une explication courte (compter de 7 en 7, compléter à la dizaine, parts deux fois plus petites, etc.).
- Le chrono ne pénalise jamais : une réponse rapide rapporte seulement un bonus.

## Îles jouables

| Île | Mini-jeu | Notion de CE2 |
|---|---|---|
| Île des Canons | Bataille des tables | Tables de multiplication dans les deux sens, division comme opération inverse |
| Stade des Vagues | Tirs au but | Calcul mental : doubles, moitiés, ×10, ×100, compléments à 100 |
| Mine aux Blocs | Le bâtisseur | Nombres jusqu'à 10 000 : milliers, centaines, dizaines, unités, écriture en lettres |
| Jungle des Créatures | Chasse sur la ligne | Placer et lire des nombres sur une droite graduée |
| Marché du Port | La bonne monnaie | Payer la somme exacte, rendre la monnaie, écriture à virgule des euros |
| Cuisine du Navire | Les parts du cuistot | Fractions jusqu'à 12, égalités (3/4 = 6/8), comparaison, additions |

Quatre îles « Bientôt » présentent des idées à valider : problèmes, heure et durées, mesures et périmètre, opérations posées.

## Récompenses

- **Prime** en pièces d'or sur un avis de recherche, avec des titres de pirate (Mousse, Matelot… jusqu'à Légende de l'Archipel).
- **Équipage** de 12 créatures originales à recruter (communes, rares et légendaires).
- **Étoiles** et passage de niveau à chaque escale.

L'univers s'inspire de l'esprit manga pirate, du foot, des blocs et des créatures à collectionner. Il n'utilise aucun personnage, logo ni nom de marque existant.

## Espace parents

On l'ouvre en maintenant le bouton appuyé pendant 2 secondes. Il affiche :

- le taux de réussite par notion ;
- le niveau atteint ;
- le temps moyen par réponse ;
- les minutes de jeu sur 7 jours ;
- les dernières erreurs (réponse donnée et bonne réponse).

On y règle aussi la durée de session et le son, et on peut tout remettre à zéro. Un bouton « Voir un exemple » montre le tableau rempli avec de fausses données.

Toutes les données restent dans le navigateur de l'appareil.
