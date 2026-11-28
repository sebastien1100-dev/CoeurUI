# Plaques de nom : tests en jeu


## 0.70.0 · nom complet

1. Plaque d'un autre joueur (ami ou ennemi) : son nom en entier, en deux parties (« Père Daikmaz »). PNJ : nom
   inchangé. Son propre familier, un joueur sans seconde partie : pas d'espace en trop.
2. Niveau : pastille ronde devant le nom, couleur de difficulté (gris très bas, vert, jaune, orange, rouge),
   chiffre sombre lisible ; élite « 27+ » : pastille plus large ; crâne « ?? » : rouge. Amis (joueurs) et
   ennemis. Réglage « Niveau » coupé : plus de pastille.

## 0.65.0 · icônes carrées

1. Icônes des effets sur les plaques de nom carrées, même quand un effet change ou se renouvelle.

## 0.25.0 · étape 1 : plaques ennemies

**Avant de commencer** : couper ce qui, dans EllesmereUI (ou un autre addon), remplace les plaques de nom.

1. **Redémarrer le jeu** (nouveau fichier). Aucune erreur Lua. `/cui version` : « 0.25.0 ».
2. `/cui` : carte « Plaques de nom » (coupée) ; tiroir avec « Ennemis ». Activer le module (puis /reload si demandé).
3. Près de monstres hostiles : plaques CœurUI (barre fine, liseré gris, nom au-dessus, niveau en petit gris devant,
   pourcentage à droite dans la barre). Plus rien du dessin du jeu dessous.
4. Monstre neutre : barre jaune. Monstre pris par un autre joueur : barre grise. Élite : « 35+ ».
5. Joueur adverse (champ de bataille, zone JcJ) : barre de la couleur de sa classe.
6. Cibler un monstre : sa plaque grandit ; en cibler un autre : la première redevient normale.
7. Clic sur une plaque : cible le monstre (comme le jeu).
8. Combat en dégâts : le liseré devient orange quand on approche de la menace du tank, rouge cœur quand le monstre nous
   attaque. En solo : rouge dès que le monstre nous tape. En tank (spécialisation) : rouge quand on perd la menace.
9. En combat : la vie et le pourcentage bougent ; aucune erreur.
10. Quête « tuer 8 gnolls » en cours : les gnolls ont le nom en jaune, un « ! » jaune à gauche et « 0/8 » dessous
    (puis « 1/8 »... comme le journal) ; quête finie : plus rien. Noter si le « ! » n'apparaît qu'hors combat.
11. Plaques amies (PNJ, joueurs alliés) : celles du jeu, inchangées.
12. Réglages « Ennemis » : largeur, hauteur, taille de la cible, niveau, pourcentage, taille du nom, quêtes (trois),
    menace et rôle. Chacun s'applique tout de suite.
13. Couper le module : demande un rechargement ; après : les plaques du jeu reviennent.
14. Langue anglaise : module « Nameplates », page « Enemies ».

## 0.26.0 · étape 2 : mes affaiblissements

1. `/reload` (pas de nouveau fichier). Aucune erreur Lua. `/cui version` : « 0.26.0 ».
2. Poser un affaiblissement (DoT, ralentissement...) sur un ennemi : un petit carré au-dessus de son nom, icône rognée,
   liseré gris fin, temps restant dessous ; il disparaît à la fin de l'effet.
3. Plusieurs effets : en ligne, centrés au-dessus du nom ; au-delà de « Nombre au plus » : cachés.
4. Effet qui se cumule : le nombre en bas à droite du carré.
5. Les affaiblissements des autres joueurs ne s'affichent pas (seulement les miens, comme le jeu).
6. En combat : les effets apparaissent, se mettent à jour et disparaissent ; aucune erreur.
7. Réglages « Mes affaiblissements » : afficher (coupé : plus rien), taille, nombre au plus.
8. Plaques amies : leurs effets comme le jeu, inchangés.
9. Poser un marqueur de raid (crâne...) sur un ennemi : il s'affiche à droite de sa plaque ; l'enlever : il disparaît.

## 0.27.0 · étape 3 : incantation

1. `/reload` (pas de nouveau fichier). Aucune erreur Lua. `/cui version` : « 0.27.0 ».
2. Ennemi qui lance un sort : barre bleu acier sous sa vie qui se remplit, nom du sort à gauche dessous, temps
   restant à droite (« 1,2 s ») ; la barre disparaît à la fin du sort.
3. Canalisation : barre verte qui se vide.
4. Sort qu'on ne peut pas interrompre : barre grise, petit cadenas devant le nom.
5. Interrompre un sort : barre rouge « Interrompu » un court instant, puis plus rien.
6. Plusieurs ennemis qui incantent en même temps : chaque plaque a sa barre, sans mélange.
7. En combat : aucune erreur ; si le jeu cache les temps, la barre bouge quand même (ou reste pleine) sans chiffres.
8. Réglages « Incantation » : afficher (coupé : plus de barre), hauteur.
9. Langue anglaise : « Interrupted », « 1.2s ».
10. Quête « tuer 8 » : « 0/8 » au début, « 1/8 » après le premier, comme le journal de quêtes.
11. En groupe : les monstres de mes quêtes ont toujours leur « ! » et mon avancement ; ceux qui ne servent qu'aux
    quêtes des autres membres n'en ont pas.

## 0.28.0 · étape 4 : plaques amies

1. `/reload` (pas de nouveau fichier). Aucune erreur Lua. `/cui version` : « 0.28.0 ».
2. Tiroir « Plaques de nom » : pages « Amis » et « Ennemis ».
3. En ville (plaques amies affichées, touche du jeu) : PNJ avec le nom seul en vert ; joueurs alliés avec le nom
   seul dans la couleur de leur classe ; plus rien du dessin du jeu.
4. Allié blessé : une barre fine sous son nom ; soigné : la barre disparaît.
5. Marqueur de raid sur un allié : à droite de son nom.
6. Clic sur une plaque amie : cible l'allié (comme le jeu).
7. Ma propre plaque (barre de ressources personnelle, si elle est activée) : celle du jeu, inchangée.
8. En donjon : plaques amies du jeu (interdites aux addons), aucune erreur ; plaques ennemies CœurUI.
9. Un PNJ qui devient hostile (ou l'inverse) : sa plaque change de style.
10. Réglages « Amis » : habiller (coupé : plaques amies du jeu tout de suite), barre si blessé, niveau devant le
    nom des joueurs (en petit gris ; jamais sur les PNJ), taille du nom,
    largeur, hauteur.
11. Langue anglaise : page « Friends ».

## 0.49.0 · style « Givre »

1. `/reload`. Aucune erreur Lua. `/cui version` : « 0.49.0 ».
2. Plaques ennemies : barre de vie dans une case sombre au double liseré discret, coins arrondis, fines stries en
   diagonale sur la couleur ; pas d'ombre. Cible : plus grande, même style.
3. Menace (tank qui perd l'aggro, soigneur qui la prend) : liseré orange puis rouge cœur ; revenu au calme : sombre.
4. Incantation : même case, stries ; bleu acier, vert (canalisation), grise au cadenas, rouge cœur un instant si
   interrompue.
5. Mes affaiblissements au-dessus du nom : cases sombres au double liseré, temps dessous.
6. Monstre de quête : barre de la couleur choisie, avancement à gauche ; pris par un autre : gris.
7. Plaque amie blessée (barre très fine, hauteur 4) : la barre reste visible dans sa case. Hauteur réglée à 2 : pas
   de dessin cassé.
