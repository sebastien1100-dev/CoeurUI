# Cadres d'unité : tests en jeu

## 0.9.0 · première version (joueur, cible, cible de la cible)

Ces tests valident aussi les pièces du noyau 0.8.0 (mode déplacement, pages sur deux colonnes, aperçu, menu
de textures).

**Avant de commencer** : couper **EllesmereUIUnitFrames** dans la liste des addons (il cache lui aussi les
cadres du jeu et dessine les siens). EllesmereUI sera retiré quand les modules de CœurUI seront prêts.

1. **Redémarrer le jeu** (nouveau fichier). Aucune erreur Lua. `/cui version` : « 0.9.0 ».
2. `/cui` : accueil avec la carte « Cadres d'unité » (coupé). À gauche, son tiroir avec Général, Joueur, Cible,
   Cible de la cible.
3. Activer le module (interrupteur de la carte). Les cadres du jeu (joueur, cible) disparaissent ; les cadres
   CœurUI apparaissent : joueur à gauche du centre, en bas.
4. Cadre du joueur : niveau, nom, vie « valeur · pourcentage » en couleur de classe, barre de ressource dessous
   (mana bleue, rage rouge, énergie jaune...), couronne si chef de groupe.
5. Cibler un PNJ hostile : cadre de la cible à droite, barre rouge, niveau (et « Élite » / « Rare » en doré si
   c'est le cas), vie en pourcentage. Neutre : jaune ; amical : vert ; joueur : couleur de classe ; PNJ déjà
   tapé par un autre : gris. Plus de cible : le cadre disparaît.
6. Cible de la cible : petit cadre sous la cible, nom et barre. Il suit quand la cible change de cible.
7. Clic gauche sur un cadre : cible l'unité. Clic droit : menu de l'unité.
8. **En combat** : les barres de vie et de ressource bougent, les textes de vie restent lisibles (aucune erreur,
   même si le jeu cache des valeurs) ; les cadres apparaissent et disparaissent avec la cible.
9. Page **Général** : police, trois tailles, texture (menu avec échantillons). L'aperçu change à chaque réglage,
   puis les vrais cadres aussi. Pas de texte d'introduction en haut de la page.
10. Page **Joueur** (deux colonnes) : largeur, hauteur, texte et couleur de la vie, puis aperçu et éléments
    (ressource, niveau, portrait, couronne). Chaque réglage change l'aperçu et le vrai cadre. Pareil pour **Cible**
    et **Cible de la cible** (sans éléments pour cette dernière).
11. Réglage changé en combat : le cadre change à la sortie du combat (pas de message « action bloquée »).
12. **Cadenas** de la barre de titre : il n'est plus gris. Clic : doré et ouvert, « Cadres déverrouillés ». Chaque
    cadre a un contour doré et son nom ; sans cible, la cible et la cible de la cible s'affichent en exemple gris.
    Le petit panneau « Déplacement des cadres » apparaît.
13. Glisser un cadre : il suit la souris. Clic droit sur un cadre : il revient à sa place d'origine.
    « Tout remettre en place » : tous reviennent. Fermer la fenêtre : le panneau reste ; « Verrouiller » ferme tout.
14. Déplacer un cadre, verrouiller, `/reload` : il est resté à sa nouvelle place.
15. Déverrouiller puis entrer en combat : tout se verrouille seul, message « combat : cadres verrouillés. ».
16. Couper le module : « coupé au prochain /reload » et bouton « Recharger l'interface ». Après le rechargement :
    les cadres du jeu sont revenus, ceux de CœurUI ont disparu.
17. Langue anglaise (Paramètres) puis rechargement : module « Unit frames », pages et cadres en anglais.

## 0.17.1 · infobulles et familier

1. `/reload`. Aucune erreur Lua. `/cui version` : « 0.17.1 ».
2. Survol du cadre du joueur, de la cible, de la cible de la cible : l'infobulle de l'unité s'affiche (nom, niveau,
   guilde...) ; elle disparaît en quittant le cadre. Module Tooltips actif : même style que les autres infobulles.
3. Chasseur ou démoniste : appeler le familier : un petit cadre « Familier » (nom, barre de vie) apparaît à gauche,
   sous le joueur ; clic gauche : cible le familier ; clic droit : son menu ; survol : son infobulle. Le renvoyer :
   le cadre disparaît.
4. Tiroir « Cadres d'unité » : nouveau sous-onglet « Familier » (largeur, hauteur, texte et couleur de la vie, aperçu).
5. Cadenas : le cadre « Familier » a son contour doré (exemple gris sans familier) et se place.
6. Langue anglaise : « Pet ».
7. Survol de son propre cadre : plus de ligne verte « Clic droit pour les paramètres de bordure ».

## 0.19.0 · barre d'incantation du joueur

**Avant de commencer** : couper la barre d'incantation d'EllesmereUI s'il en dessine une.

1. `/reload`. Aucune erreur Lua. `/cui version` : « 0.19.0 ».
2. Lancer un sort avec un temps d'incantation (ex. Boule de feu) : une barre bleue apparaît collée sous le cadre du
   joueur, à sa largeur ; icône à gauche, nom du sort, temps « 1,4 / 2,5 » à droite ; petite zone gris sombre au
   bout (latence). À la fin : pleine et plus claire un instant, puis elle s'efface. Plus de barre du jeu.
3. Canalisation (ex. Projectiles des arcanes, Drain de vie) : barre verte qui se vide, avec des repères pour les tics.
4. Bouger pendant une incantation (ou se faire interrompre) : barre rouge « Interrompu », puis elle s'efface.
   Appuyer de nouveau sur le sort pendant l'incantation : la barre continue normalement (pas d'« Échec »).
5. Se faire frapper pendant une incantation : la barre recule (temps repoussé) et suit.
6. Page **Joueur** : section « Barre d'incantation » sous « Textes et couleurs », section « Éléments de
   l'incantation » à droite. Chaque réglage change la barre (au prochain sort). Option coupée : tous les réglages
   de l'incantation grisés ; la barre du jeu revient.
7. « Détacher du cadre » : la largeur se règle ; cadenas ouvert : la barre « Incantation » a son contour doré et un
   exemple gris-bleu ; la placer, verrouiller, `/reload` : elle est restée. Réattacher : elle revient sous le cadre.
8. Temps affiché « Restant » puis « Aucun » ; hauteur plus grande : le texte grandit un peu.
9. En combat : rien de bloqué, aucune erreur.
10. Langue anglaise : « Cast bar », temps « 1.4 / 2.5 ».
11. Familier appelé : son cadre est sous la barre d'incantation (sans la chevaucher). Détacher la barre ou la couper :
    il remonte juste sous le cadre du joueur ; la rattacher : il redescend. Changer la hauteur de la barre : il suit.
12. Déplacer le cadre du joueur avec le cadenas : le familier le suit. Déplacer le familier, verrouiller, `/reload` :
    il garde sa place par rapport au joueur.
