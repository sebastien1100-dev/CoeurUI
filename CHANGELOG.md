# CœurUI : notes de version

La plus récente en premier. Phrases courtes, du point de vue du joueur.

## 0.10.0 · 26/11/2026

- Nouveau module « Minicarte » (coupé d'office) : minicarte sobre, carrée ou rectangulaire (largeur et hauteur
  réglables), avec le nom de la zone, les coordonnées en bas de la carte et le zoom à la molette.
- Boutons du jeu gardés : courrier, suivi, file d'attente. Plus d'heure ni de calendrier sur la carte.
- Les boutons des addons sont rangés dans un tiroir qui s'ouvre d'un clic.
- Avec le cadenas, on place la carte, le nom de la zone, le tiroir et chaque bouton du jeu ; les éléments suivent la
  carte quand on la déplace.
- Couper le module demande un rechargement de l'interface.
- Redémarrer le jeu.

## 0.9.0 · 26/11/2026

- Nouveau module « Cadres d'unité » (coupé d'office) : cadres du joueur, de la cible et de la cible de la cible, à
  la place de ceux du jeu. Couper le module demande un rechargement de l'interface.
- Page « Général » : police, taille de chaque libellé (nom, niveau, vie) et texture des barres, pour tous les cadres.
- Pages Joueur, Cible, Cible de la cible : taille, texte et couleur de la vie, éléments, avec un aperçu.
- Le cadenas de la fenêtre déverrouille les cadres pour les placer à la souris.
- Redémarrer le jeu.

## 0.8.0 · 26/11/2026

- Le module « Essai », qui servait aux tests, est retiré. S'il était actif, la plaque des PNJ amis revient à son
  réglage d'origine.
- Un cadenas dans la barre de titre servira à déverrouiller les cadres pour les déplacer (avec les prochains
  modules qui ont des cadres).
- La version de CœurUI s'affiche dans la barre de titre de la fenêtre.
- Correction : « Paramètres » avait un trait doré à gauche alors qu'il n'était pas choisi.
- Redémarrer le jeu.

## 0.7.0 · 26/11/2026

- Nouvelle page « Paramètres », en bas à gauche de la fenêtre : réglages généraux de CœurUI.
- CœurUI parle anglais : choix de la langue dans « Paramètres » (par défaut celle du jeu), après un
  rechargement de l'interface. Les commandes marchent en français et en anglais (`/cui help`, `enable`, `disable`).
- Le bouton de minicarte n'est plus un module : on l'affiche ou le cache dans « Paramètres ». Sa place est gardée.
- Correction : « Paramètres » avait une pastille blanche, comme un module, alors que ce n'en est pas un.
- Redémarrer le jeu.

## 0.6.0 · 26/11/2026

- Nouvelle fenêtre principale (`/cui` ou le bouton de minicarte) : les modules sont rangés à gauche, en tiroirs
  qui s'ouvrent sur leurs sous-modules.
- Accueil « Tous les modules » : une carte par module, avec son interrupteur et un lien vers ses réglages.
- Les réglages d'un module ou d'un sous-module s'ouvrent à droite ; la molette fait défiler les longues pages.

## 0.5.0 · 26/11/2026

- Nouveau module « Bouton de minicarte », actif d'office : un clic ouvre la fenêtre des modules, on le glisse
  autour de la minicarte pour le déplacer.
- Correction : rangé par un addon de minicarte (EllesmereUIMinimap), le contour doré du bouton était coupé.
- Redémarrer le jeu.

## 0.4.0 · 26/11/2026

- Fenêtre « Modules » : bouton « Réglages » sur la ligne d'un module qui a des réglages ; son panneau s'ouvre dans
  la même fenêtre, retour par « « Modules ».
- Les réglages s'appliquent tout de suite ; « Valeurs par défaut » remet tout à zéro.
- Nouveaux curseur et menu déroulant.
- Correction : le bouton rond du curseur était caché sous son liseré (on ne voyait qu'un trou).
- Redémarrer le jeu.

## 0.3.0 · 26/11/2026

- Fenêtre « Modules » : bouton « Recharger l'interface » quand un module attend un /reload pour être coupé.
- En combat, ce bouton est grisé et revient à la sortie du combat.
- Redémarrer le jeu.

## 0.2.0 · 26/11/2026

- Nouvelle fenêtre « Modules » : `/cui` l'ouvre, un interrupteur par module pour l'activer ou le couper.
- La fenêtre se déplace par sa barre de titre et garde sa place ; Échap la ferme.
- L'aide des commandes passe par `/cui aide`.
- Redémarrer le jeu.

## 0.1.1 · 26/11/2026

- CœurUI a maintenant son icône dans la liste des addons.
- Couleurs du thème accordées à celles de l'icône (or, rouge du cœur).
- Redémarrer le jeu.

## 0.1.0 · 26/11/2026

- Première version : CœurUI se charge et garde ses réglages d'une session à l'autre.
- Commande `/cui` : version, liste des modules, activer ou couper un module, remise à zéro.
- Un module coupé rend au jeu les réglages qu'il avait changés, même après une déconnexion.
- Un module activé ou coupé en combat l'est à la sortie du combat.
- Module « Essai » pour tester le noyau (sera retiré avant la publication).
- Redémarrer le jeu.
