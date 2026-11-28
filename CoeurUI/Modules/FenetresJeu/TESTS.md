# Skin Blizzard : tests en jeu

## 0.61.0 · page Monnaies

1. **Redémarrer le jeu** (nouveau fichier). Aucune erreur Lua. Fiche, onglet pièces.
2. Sans monnaie : liste vide sans décor, traits sombres en haut et en bas, défilement fin ; à droite
   « Sélectionnez une monnaie... » en gris.
3. Avec une monnaie (à vérifier dès qu'il y en a une) : section repliable en petites capitales ; ligne :
   icône carrée dans une petite case, nom gris clair, quantité blanche ; survol : bande plus claire.
4. Détail d'une monnaie : titre en gras, trait, texte gris ; cases « Inutilisée », « Montrer dans le sac »
   de CœurUI ; bouton « Transférer » de CœurUI.
5. Journal des transferts (si la monnaie se transfère) : cadre de CœurUI, croix grise, plus de métal.

## 0.60.0 · page JcJ

1. **Redémarrer le jeu** (nouveau fichier). Aucune erreur Lua. Fiche, onglet épées croisées.
2. « SAISON 1 » en petites capitales grises, « Civil/civile » en gras blanc, trait sombre dessous.
3. Blason de la faction du jeu dans un médaillon rond sombre (double liseré, ombre) ; plus d'anneau doré ni
   de lueur ; rang « 0 » dans une petite case dessous.
4. « Points de rang » à gauche, « 0 / 750 » à droite ; barre striée vide (bleue Alliance, rouge Horde) ;
   dessous « 750 points pour le rang 1 ».
5. Détail : « Civil/civile » en gras, trait, texte gris, « Augmentation du plafond cette semaine : 1800 » ;
   « RÉCOMPENSES AU RANG 1 » en petites capitales sur un trait ; tabard dans une case du thème, nom blanc.

## 0.59.0 · page Statistiques

1. **Redémarrer le jeu** (nouveau fichier). Aucune erreur Lua. Fiche, onglet courbe.
2. Sections (« PERSONNAGE », « DONJONS ET RAIDS »...) : petites capitales grises, chevron ; clic : la
   section se déplie (chevron vers le bas) et se replie.
3. Sous-sections (« Boss », « Champs de bataille ») : petite case sombre avec un chevron gris (vers la
   droite : repliée, vers le bas : dépliée), nom en blanc ; clic : elle se déplie, le chevron suit.
4. Lignes : nom en gris clair, valeur (« -- », « 79 ») en blanc ; survol : bande plus claire.
5. Barre de défilement fine ; molette : la liste défile ; replier, déplier, défiler : tout reste habillé.

## 0.58.0 · page Compétences

1. **Redémarrer le jeu** (nouveau fichier). Aucune erreur Lua. Fiche, onglet marteau.
2. « MÉTIERS », « COMPÉTENCES D'ARMES »... : petites capitales grises, chevron, trait sombre ; clic : la
   section se replie et revient.
3. Compétences : noms gris clair ; barres striées gris bleuté dans une case, « 23 / 30 » blanc lisible ;
   survol et ligne choisie : bande plus claire.
4. Détail à droite (cliquer « Minage ») : nom en gras blanc, traits sombres, barre « 1 / 75 » pareille,
   description en gris clair ; choisir une arme (Épées) : intertitres « CONTRE LES BOSS DE RAID »,
   « ADVERSAIRE DE NIVEAU ÉGAL » en petites capitales grises sur un trait, plus de bandeau doré ; changer
   de compétence : pareil.
5. Réputation : rien n'a changé (barres de la couleur de l'attitude).

## 0.57.0 · page Réputation

1. **Redémarrer le jeu** (nouveau fichier). Aucune erreur Lua. Ouvrir la fiche, onglet médaille.
2. « ALLIANCE » : petites capitales grises, chevron vers le bas, trait sombre dessous ; clic : la section se
   replie (chevron vers la droite), re-clic : elle revient ; survol : texte et chevron blancs.
3. Factions : noms en gris clair ; barre striée dans une case sombre, de la couleur de l'attitude, texte
   « Amical » blanc lisible ; survol d'une ligne et ligne choisie : bande un peu plus claire.
4. Détail à droite : « Darnassus » en gras blanc, « Amical » en gris, traits sombres, barre « 112 / 6000 »
   comme celles de la liste, description en gris clair.
5. Cases à cocher : petites cases sombres ; cocher « Barre de réputation » : coche blanche, libellé blanc,
   la barre de réputation suit ; « En guerre » grisé quand le jeu l'interdit ; survol : liseré doré.
6. Barre de défilement fine ; molette : la liste défile.

## 0.56.0 · page Personnage finie

1. **Redémarrer le jeu** (nouvelles icônes). `/cui version` : « 0.56.0 ». Aucune erreur Lua à l'ouverture de la fiche.
2. Cases d'équipement carrées, icône carrée ; case vide : unie, sans dessin ; au survol, l'infobulle nomme
   l'emplacement.
3. Résistances : cinq petites cases sombres avec nos icônes grises (étoile, flamme, flocon, feuille,
   croissant de lune), dans le bon ordre (Arcanes, Feu, Givre, Nature, Ombre).
3 bis. Petits onglets du haut : un seul ouvert (case plus claire, liseré gris clair) ; survol d'un autre :
   liseré gris et icône blanche ; l'état suit les clics.
4. Petit onglet cuirasse ouvert : à côté de chaque case, une petite case avec un chevron gris tourné vers
   l'extérieur (droite à gauche de la fiche, gauche à droite, haut sous les armes) ; clic : la liste des
   pièces s'ouvre comme avant : panneau ardoise avec ombre, choix en cases du thème (liseré de qualité),
   plus de cadre doré ni de liseré jaune autour de la case ouverte ; un clic sur un choix l'équipe.
   Bouton « Nouvel ensemble » : « + » au trait et texte gris clair (blancs au survol), plus de vert ; sur
   une ligne, au-dessus de « Équiper » et « Sauver », de leur largeur. Dans le menu de choix : « Mettre dans
   les sacs » = sac et flèche au trait, « Ignorer » = cercle barré ; ils marchent comme avant.
6. Le personnage tient entier dans sa case (pieds compris) ; zoom et rotation marchent ; les boutons
   restent lisibles.
8. Survol d'une case d'équipement (et d'un choix du menu) : liseré doré, or clair en appuyant, comme les
   barres d'actions.
7. Glisser la fiche par son bandeau (le nom en haut) : elle suit ; la fermer, la rouvrir : même place ;
   après un /reload : même place ; ouvrir le grimoire à côté : la fiche ne revient pas à sa place d'origine.
5. Passer sur Réputation, Compétences... : le titre reste « Chouf Maurice » en blanc ; la page est écrite
   en haut à gauche.

## 0.55.0 · fiche complète (icônes, plus d'or)

1. **Redémarrer le jeu** (nouvelles icônes). `/cui version` : « 0.55.0 ».
2. Onglets de côté : nos icônes au trait (silhouette, médaille, marteau, épées croisées, pièces, courbe), grises,
   blanches au survol ; l'ouvert : case plus claire, liseré gris clair, icône blanche. Plus de liseré doré.
3. En haut à gauche de la fiche, le nom de la page ouverte en petites capitales (« PERSONNAGE »,
   « RÉPUTATION »...) ; il change avec l'onglet.
4. « Guerrier de niveau 6 » : « Guerrier » en blanc, « de niveau 6 » en gris clair ; pas de jaune.
5. Boutons sous le titre : loupe +, loupe -, flèche à gauche, flèche à droite, retour ; chacun fait bien ce
   que son icône montre.
6. Fond sombre du personnage : entre les deux colonnes d'équipement seulement, pas sous les cases.
7. Survol d'une case d'équipement, du bouton flèche, d'un petit onglet : liseré gris clair, jamais doré.

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
