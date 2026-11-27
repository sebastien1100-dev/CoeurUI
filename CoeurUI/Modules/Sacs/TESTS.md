# Sacs et banque : tests en jeu

## 0.29.0 · étape 1 : les sacs

**Avant de commencer** : couper ce qui, dans EllesmereUI (ou un autre addon), remplace les sacs.

1. **Redémarrer le jeu** (nouveaux fichiers). Aucune erreur Lua. `/cui version` : « 0.29.0 ».
2. `/cui` : carte « Sacs et banque » (coupée) ; l'activer (puis /reload si demandé).
3. Touche des sacs (B) : la fenêtre CœurUI s'ouvre, plus aucun sac du jeu ; B de nouveau : elle se ferme.
   Échap la ferme aussi. Clic sur le sac à dos ou un sac de la barre : même chose.
4. Par catégories : sections Équipement, Consommables, Composants d'artisanat, Quêtes, Divers, Camelote, Places
   libres ; seules celles qui ont des objets sont là.
5. Sac de composants (herbes...) ou carquois : à part en bas, avec son nom et « x libres sur y ».
6. Cases : liseré vert, bleu, violet selon la qualité (gris fin sinon) ; niveau d'objet en bas à gauche de
   l'équipement ; nombre en bas à droite ; camelote un peu éteinte.
7. Ramasser un objet : pastille rouge sur sa case ; la survoler : la pastille disparaît.
8. Clic droit : utiliser ou équiper ; glisser une case sur une autre ; Maj-clic : lien dans la discussion ;
   survol : infobulle de l'objet.
9. Potion ou pierre de foyer utilisée : le temps de recharge tourne sur la case.
10. Recherche : taper « potion » : le reste s'assombrit ; Échap dans le champ : tout revient.
11. Bas : sacs équipés (survol : infobulle ; cliquer pour le prendre, poser un sac dessus pour le mettre), places
    libres, argent (po, pa, pc colorés) qui suit les gains et dépenses.
12. Chez un marchand : la fenêtre s'ouvre toute seule ; vendre un objet (clic droit) marche.
13. Réglages : par catégories (coupé : une seule grille), sacs à part, cases par rangée, taille, espacement, niveau
    d'objet, liseré de qualité, pastille. Chacun s'applique tout de suite.
14. Cadenas : un cadre « Sacs » à placer ; la fenêtre grandit vers le haut et la gauche depuis son coin bas droit ;
    `/reload` : elle est restée.
14b. Glisser la barre de titre (« Sacs ») : la fenêtre suit la souris ; la lâcher : elle reste là, même après
    `/reload` ; la croix ne déclenche pas de déplacement.
14c. Bouton « tiroir » (à gauche de la croix) : les emplacements de sac en bas disparaissent, les places libres
    se décalent à gauche ; de nouveau : ils reviennent ; `/reload` : le choix est gardé. Survol : infobulle.
14d. Bouton « liste » (à gauche du tiroir) : clic : tout en vrac, une seule grille ; clic : retour aux catégories ;
    l'infobulle dit ce que fera le clic ; le réglage du panneau suit.
15. En combat : ouvrir les sacs et utiliser une potion marchent ; aucune erreur.
16. La banque (chez le banquier) : encore celle du jeu à cette étape, ses sacs s'ouvrent normalement.
17. Langue anglaise : « Bags », « EQUIPMENT », « 12g 34s 5c ».
