# Effets : tests en jeu

## 0.65.0 · icônes carrées

1. Icônes des effets carrées, à l'apparition d'un nouvel effet comme après un /reload ; durée et nombre
   de charges lisibles.

## 0.23.0 · première version

**Avant de commencer** : couper le module d'EllesmereUI qui habille les effets, s'il y en a un.

1. **Redémarrer le jeu** (nouveau fichier). Aucune erreur Lua. `/cui version` : « 0.23.0 ».
2. `/cui` : carte « Effets » (coupée) ; tiroir avec « Améliorations » et « Affaiblissements ». Activer le module.
3. Améliorations en haut à droite : carrés sobres, liseré gris fin, plus de décor du jeu ; temps restant dessous
   (« 54 min », « 45 s ») en gris clair, en blanc sous 10 secondes ; effets sans durée : rien dessous.
4. Effet qui se cumule : le nombre en bas à droite de l'icône.
5. Recevoir un affaiblissement (magie, poison, malédiction, maladie) : sur sa propre ligne, plus grand, liseré de la
   couleur du type.
6. Survol : l'infobulle de l'effet. Clic droit sur une amélioration (hors combat) : elle disparaît.
7. En combat : les effets apparaissent, disparaissent et se mettent à jour ; aucune erreur ni « action bloquée ».
8. Cadenas : deux cadres, « Améliorations » et « Affaiblissements », à placer séparément ; `/reload` : ils sont
   restés.
9. Page « Améliorations » : taille, par rangée, rangées au plus (au-delà : effets cachés), espacement, sens (les
   quatre), temps, blanc sous 10 s, nombre, tailles des textes. Chaque réglage change seulement les améliorations.
9b. Changer la taille (ou par rangée, espacement, rangées) : le groupe reste collé du côté d'où partent les
    icônes (à droite pour « vers la gauche », à gauche pour « vers la droite ») ; `/reload` : même place.
10. Page « Affaiblissements » : pareil, plus « Couleur du type » (coupé : liseré gris). Change seulement les
    affaiblissements.
11. « Afficher les améliorations » coupé : plus d'améliorations (les affaiblissements restent).
12. Le petit bouton du jeu pour replier les améliorations a disparu.
13. Couper le module : demande un rechargement ; après : les effets du jeu reviennent comme avant.
14. Langue anglaise : module « Auras », pages « Buffs » et « Debuffs ».

## 0.52.0 · style « Givre »

1. `/reload`. Aucune erreur Lua. `/cui version` : « 0.52.0 ».
2. Améliorations : chaque icône dans une case sombre au double liseré discret, coins arrondis, ombre douce
   dessous ; temps sous l'icône (blanc sous 10 s), nombre en bas à droite.
3. Affaiblissement (magie, malédiction, poison, maladie) : liseré extérieur de la couleur du type ; physique :
   rouge cœur. En combat : la couleur suit toujours.
4. Taille réglée plus grande ou plus petite : la case et l'ombre suivent ; clic droit pour annuler : comme avant.
