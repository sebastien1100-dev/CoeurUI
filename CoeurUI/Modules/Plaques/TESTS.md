# Plaques de nom : tests en jeu

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
10. Quête « tuer 8 gnolls » en cours : les gnolls ont le nom en jaune, un « ! » jaune à gauche et « 3/8 » (ce qu'il
    reste) dessous ; quête finie : plus rien. Noter si le « ! » n'apparaît qu'hors combat.
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
