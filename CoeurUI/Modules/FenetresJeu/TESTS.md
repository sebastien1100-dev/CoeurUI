# Skin Blizzard : tests en jeu

## 0.54.0 · fiche du personnage

1. **Redémarrer le jeu** (nouveaux fichiers). Aucune erreur Lua. `/cui version` : « 0.54.0 ».
2. Activer « Skin Blizzard » dans la fenêtre de CœurUI. Sa page (sans tiroir) : interrupteur « Fiche du personnage » actif.
3. Ouvrir la fiche (C) : cadre ardoise au double liseré discret avec une ombre douce ; plus de portrait rond, de
   décor doré ni de fond de pierre ; « Chouf Maurice » en haut au centre, trait sombre dessous ; croix grise,
   blanche au survol, elle ferme la fiche.
4. Personnage sur un fond sombre ; boutons zoom, rotation, retour en petites cases grises (liseré doré au survol),
   ils marchent.
5. Cases d'équipement : cases sombres ; objet blanc ou gris : liseré sombre ; objet vert ou bleu : liseré de sa couleur ; survol : liseré doré, infobulle
   de l'objet ; case vide : le dessin de l'emplacement très pâle. Changer une pièce d'équipement : la case suit.
   Clic droit, glisser un objet sur une case : comme avant.
6. Statistiques : « GÉNÉRAL », « CARACTÉRISTIQUES PRINCIPALES », « ARMES » en petites capitales grises sur un trait
   sombre ; une ligne sur deux légèrement plus claire ; barre de défilement fine, la molette fait défiler.
7. Bouton flèche à côté de « Guerrier de niveau 6 » : petite case, chevron ; clic : les statistiques se replient
   et le chevron se retourne.
8. Onglets de côté : cases sombres collées à la fiche ; l'ouvert a son icône vive et un liseré doré, les autres
   une icône un peu terne. Les onglets marchent (réputation, monnaies... gardent leur contenu du jeu).
9. Les trois petits onglets en haut des statistiques : petites cases avec nos icônes au trait (toile des caractéristiques, cuirasse,
   trois traits pour les titres), grises au repos, blanches au survol et sur l'ouvert (liseré gris clair, pas de cadre jaune ni brun) ;
   case des munitions (en bas, à droite des armes) au même style. Titres, ensembles d'équipement : listes au même style,
   boutons « Équiper », « Sauver », « Nouvel ensemble » au style de CœurUI.
10. Couper l'interrupteur : « au prochain /reload » ; après le /reload, la fiche du jeu revient telle quelle.
11. `/cui cadre CharacterFrame` : fenêtre « Pièces du cadre » avec l'arbre de la fiche (outil pour les fenêtres
    suivantes).
