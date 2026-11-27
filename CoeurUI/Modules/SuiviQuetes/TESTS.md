# Suivi des quêtes : tests en jeu

## 0.18.0 · première version

**Avant de commencer** : couper **EllesmereUIQuestTracker** dans la liste des addons (il change lui aussi le suivi).
Le module ne dépend de rien chez EllesmereUI. Avoir quelques quêtes suivies, dont une avec une barre de progression.

1. **Redémarrer le jeu** (nouveau fichier). Aucune erreur Lua. `/cui version` : « 0.18.0 ».
2. Activer « Suivi des quêtes ». Le suivi passe à droite, sous la minicarte, sans le décor du jeu : titres de section
   gris, titres de quête colorés (gris, vert, jaune, orange, rouge selon le niveau), objectifs gris clair, objectif
   fait en vert avec sa coche. Fond sombre léger derrière les quêtes seulement.
3. Barre de progression (objectif bonus, pourcentage) : fine, gris clair sur fond graphite.
4. Clic gauche sur une quête : le journal s'ouvre sur elle. Maj + clic : lien dans la discussion. Clic droit : le menu
   du jeu avec, en bas, « Lien Wowhead ».
5. « Lien Wowhead » : petite fenêtre CœurUI, titre avec le nom de la quête, adresse `https://fr.wowhead.com/quest=…`
   sélectionnée. Ctrl+C puis coller dans le navigateur : la page de la quête s'ouvre. Taper dans la case : l'adresse
   revient. Clic dans la case : l'adresse reste sélectionnée. Plus de bouton « Sélectionner » (0.19.1). Échap ou
   « Fermer » : la fenêtre se ferme.
6. Page de réglages : largeur (le suivi s'élargit, les textes passent sur moins de lignes), hauteur maximale (au-delà,
   le suivi défile), tailles des titres et des objectifs (le suivi se réarrange sans chevauchement).
7. Fond : décocher (plus de fond) ; opacité 100 % puis 0 % ; recocher.
8. Repli : « Replier en combat » coché : à l'entrée en combat, le suivi se replie ; à la sortie, il se déplie. Entrer
   dans un donjon (repli en donjon coché par défaut) : replié ; sortir : déplié. Replier le suivi à la main hors donjon :
   il reste replié.
9. Cadenas : « Suivi des quêtes » a son contour doré (largeur × hauteur maximale) et se place. `/reload` : place gardée.
10. Couper le module : « coupé au prochain /reload ». Après le rechargement : le suivi du jeu comme avant.
11. Langue anglaise : « Quest tracker », « Wowhead link », adresse `www.wowhead.com`.
12. Plus de ligne « Tous les objectifs » en haut du suivi (ni son bouton) ; le suivi commence à « Quêtes ». Le fond
    entoure les quêtes avec la même marge des quatre côtés, icônes des quêtes comprises ; il suit quand une quête
    s'ajoute ou se termine, et quand une section se replie.
13. Objectifs : 0/8 en rouge, 4/8 en jaune, 7/8 presque vert, 8/8 vert ; barre « 62 % » : jaune-vert. Une quête
    terminée : « À rendre » en vert. Une ligne sans nombre d'une quête en cours : gris clair.

## 0.38.0 · défilement

1. Défilement : suivre beaucoup de quêtes (plus que la hauteur) : molette sur le suivi : il défile, le fond reste
   dans le cadre ; tout en bas, il s'arrête. En combat : la molette ne fait rien, aucune erreur.
2. Couper « Faire défiler à la molette » : le suivi revient en haut, les quêtes en trop sont cachées comme avant.

## 0.39.0 · avancée en début de ligne

1. /reload. `/cui version` : « 0.39.0 ». Réglages, Textes : « Avancée en début de ligne » (actif).
2. Objectifs à compter : « 0/12 Glande à venin d'Aile-fière », « 3/8 Récupérateur gueule-de-dragon » (sans
   « personnages tués ») ; couleur selon l'avancée inchangée ; les autres lignes (« Parler à... ») ne changent pas.
3. Tuer un monstre de quête : le nombre monte, toujours en début de ligne.
4. Couper le réglage : à la prochaine mise à jour du suivi, « Glande à venin d'Aile-fière : 0/12 ».

## 0.40.0 · notre suivi, étape 1 : quêtes et objectifs

1. **Redémarrer le jeu** (nouvelle icône). Aucune erreur Lua. `/cui version` : « 0.40.0 ».
2. Les quêtes suivies sont dans notre liste, rangées par zone ; la zone où tu es en premier, avec « ici » ; les
   autres dans l'ordre du journal. Plus de quêtes en double dans le suivi du jeu.
3. Clic sur un titre de zone : elle se replie (chevron tourné), clic : elle se déplie ; /reload : elle est restée
   repliée (réglage « Garder les zones repliées »).
4. Titre : [niveau], couleur de la difficulté, (Donjon) / (Élite) en gris ; pastille « ! » ou « ? » ; objectifs
   « 0/12 Glande... » rouge » jaune » vert ; coche verte quand fait ; « À rendre » quand la quête est finie ; les
   quêtes à rendre en tête de leur zone.
5. Clic sur une quête : le journal s'ouvre sur elle ; Maj-clic : son lien dans la discussion.
6. Clic droit : menu avec ouvrir, ne plus suivre, partager (en groupe), lien dans la discussion, chercher un
   groupe (« LFG [quête] » en anglais, prêt dans la discussion, à envoyer avec Entrée), lien Wowhead,
   abandonner (le jeu demande confirmation).
7. Peu de quêtes : le cadre est juste assez haut (il grandit vers le bas). Beaucoup : il s'arrête à la hauteur
   maximale et la molette le fait défiler ; le titre de la zone en cours reste en haut, sans bande plus sombre ;
   rien ne passe à travers lui.
8. Accepter, finir, rendre une quête, en suivre une de plus : la liste suit tout de suite.
9. Réglages : par zone (coupé : une seule liste), quêtes à rendre en premier, tailles, avancée en début de ligne,
   largeur, hauteur, défilement, fond et opacité, repli en combat / en donjon (seuls les titres de zone restent).
10. Reste du suivi du jeu (campagne, objectifs bonus...) : sous notre liste, même style ; réglage coupé : caché.
11. Cadenas : cadre « Suivi des quêtes » à placer ; /reload : il est resté.
