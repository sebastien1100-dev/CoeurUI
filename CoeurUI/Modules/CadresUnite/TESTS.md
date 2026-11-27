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

## 0.20.0 · barre d'incantation de la cible

1. `/reload`. Aucune erreur Lua. `/cui version` : « 0.20.0 ».
2. Cibler un PNJ qui incante (mage, prêtre...) : barre bleue collée sous le cadre de la cible, icône, nom, temps.
   Pas de zone de latence. Sort fini : la barre s'efface.
3. Le couper (coup de pied, contresort...) : rouge « Interrompu », puis s'efface.
4. Sort qu'on ne peut pas interrompre (boss, bouclier) : barre grise avec un petit cadenas devant le nom. En combat,
   si le jeu cache cette information, la barre reste bleue (pas d'erreur).
5. Canalisation de la cible (Drain de vie...) : verte, se vide, avec des repères de tics.
6. Changer de cible pendant qu'elle incante : la barre montre aussitôt l'incantation de la nouvelle cible (ou se
   cache si elle n'incante rien). Plus de cible : plus de barre.
7. En combat, si le jeu cache le temps : la barre avance sans chiffres, ou reste pleine ; aucune erreur.
8. Page **Cible** : section « Barre d'incantation » à gauche, « Éléments de l'incantation » à droite (icône, nom,
   tics, « Gris + cadenas... »), sans aperçu de la barre. Couper l'option : réglages grisés, plus de barre.
9. « Détacher du cadre » : cadenas ouvert, cadre « Incantation de la cible » avec un exemple, au centre de l'écran ;
   le placer, `/reload` : il est resté.
10. Cible de la cible : son cadre est sous la barre de la cible (sans la chevaucher), aligné à droite ; il remonte
    quand on détache ou coupe la barre. Il suit la cible quand on la déplace.
11. La barre du joueur marche toujours comme en 0.19.0.
12. Langue anglaise : « Target cast bar ».

## 0.33.0 · cadres de groupe, étape 1 : les cadres

1. **Redémarrer le jeu** (nouveaux fichiers). Aucune erreur Lua. `/cui version` : « 0.33.0 ».
2. `/cui` › Cadres d'unité : nouvelle page « Groupe ». Seul : aucun cadre de groupe à l'écran.
3. Cadenas ouvert : cadre « Groupe » à placer et groupe de test de 5 (guerrier, prêtre, mage, chasseur,
   démoniste) : vies qui bougent, chasseur qui pâlit par moments, démoniste « Mort » par moments, couronne sur
   le guerrier, étoile sur le mage, liseré blanc sur le prêtre, rouge sur le guerrier. Cadenas fermé : il part.
4. Cadenas ouvert, changer les réglages : sens (4 choix), largeur, hauteur, espacement, texte de la vie,
   couleur, rôle, ressource, chef, marqueur, pâlir et son opacité : le groupe de test suit tout de suite.
   « M'afficher » coupé : 4 cadres.
5. En groupe : plus de cadres de groupe du jeu ; les nôtres, toi compris, dans l'ordre choisi.
6. Tri par rôle : tank, soigneur, puis dégâts (rôles posés par l'outil de recherche ou le chef). Par nom, par
   classe, ordre du groupe : l'ordre change (hors combat).
7. Clic gauche : cible l'équipier (liseré blanc) ; clic droit : menu du jeu ; survol : infobulle.
8. Un équipier s'éloigne : son cadre pâlit ; il revient : normal.
9. Un équipier meurt : « Mort », barre grise ; fantôme : « Fantôme » ; se déconnecte : « Déconnecté ».
10. Marqueur de raid posé sur un équipier : il apparaît en haut à droite de son cadre.
11. Combat : un équipier rejoint ou quitte le groupe : les cadres suivent, aucune erreur.
12. Réglage changé en combat : appliqué à la sortie du combat, aucune erreur.
13. Couper « Cadres de groupe de CœurUI » : nos cadres partent ; /reload : ceux du jeu reviennent.

## 0.34.0 · cadres de groupe, étape 2 : les effets

1. /reload. `/cui version` : « 0.34.0 ». Page « Groupe » : section Effets (soins à venir, mes soins sur la
   durée, affaiblissements à dissiper, seulement ma classe, effets au plus, taille des effets).
2. Cadenas ouvert : guerrier avec un soin sur la durée (liseré vert), prêtre avec un poison (liseré vert de
   poison), mage avec une magie (liseré bleu) et un soin, et un bout de vie vert clair (soins à venir). Les
   durées tournent et repartent. Chaque réglage d'effet change le groupe de test.
3. En groupe, un soigneur soigne un équipier : la vie de l'équipier se prolonge en vert clair pendant le sort.
4. (Classe qui soigne sur la durée) Lancer un soin sur la durée : icône sur le cadre, liseré vert, durée qui
   tourne ; une amélioration longue (endurance...) n'apparaît pas hors combat.
5. (Classe qui dissipe) Un équipier prend un affaiblissement que tu peux dissiper : icône, liseré de son type ;
   le dissiper : l'icône part. Un affaiblissement que ta classe ne dissipe pas : rien (option active) ; option
   coupée : il apparaît s'il a un type.
6. En combat : les icônes suivent toujours, aucune erreur.
7. Cadenas ouvert : « Place » des soins et des affaiblissements (4 coins, centre) : les icônes du groupe de test
   bougent ; au centre, le rang est centré ; deux sortes au même coin peuvent se chevaucher.
8. Taille des icônes des soins et des affaiblissements : chacune change seule.
9. Groupe de test : liseré du prêtre vert (poison), du mage bleu (magie). En groupe, un équipier avec un
   affaiblissement à dissiper : liseré de sa couleur ; dissipé : liseré normal. Réglage coupé : liseré normal.

## 0.35.0 · cadres de groupe, étape 3 : les familiers

1. /reload. `/cui version` : « 0.35.0 ». Page « Groupe », Éléments : « Familiers des équipiers » (actif).
2. Cadenas ouvert : petit cadre « Familier » sous le chasseur et sous le démoniste ; les cadres ne se chevauchent
   pas (colonne et ligne). Réglage coupé : ils partent et les cadres se resserrent.
3. En groupe, un équipier appelle un familier : son cadre apparaît sous lui ; il le renvoie : il part. Pareil
   pour ton propre familier (« M'afficher » actif).
4. Clic sur le cadre d'un familier : il est ciblé ; clic droit : son menu ; survol : son infobulle.
5. Vie du familier qui baisse et remonte ; il meurt : barre vide.
6. Combat : un familier appelé ou renvoyé : son cadre suit, aucune erreur.

## 0.36.0 · familiers détachés

1. /reload. `/cui version` : « 0.36.0 ». Page « Groupe » : « Familiers détachés » (coupé), sous « Familiers des
   équipiers ».
2. L'activer, cadenas ouvert : nouveau cadre « Familiers du groupe » ; les familiers d'exemple y sont, l'un sous
   l'autre ; les cadres du groupe se resserrent. Le déplacer : il bouge seul ; /reload : il est resté.
3. En groupe : les familiers des équipiers (et le tien) dans la colonne à part ; clic : cibler ; clic droit : menu.
4. Le couper : les familiers reviennent sous leur maître ; plus de cadre « Familiers du groupe » au cadenas.
5. Combat : un familier appelé ou renvoyé : la colonne suit, aucune erreur.

## 0.37.0 · cadres de boss

1. **Redémarrer le jeu** (nouveau fichier). Aucune erreur Lua. `/cui version` : « 0.37.0 ». Page « Boss ».
2. Cadenas ouvert : cadre « Boss » à droite et 5 boss d'exemple : vies qui bougent, crâne sur le premier, liseré
   blanc sur le deuxième, incantation bleue sur le deuxième, grise avec cadenas sur le troisième, affaiblissements
   à gauche des deux premiers. Chaque réglage change l'exemple tout de suite. Cadenas fermé : ils partent.
3. Rencontre avec un boss (donjon) : plus de cadres de boss du jeu ; les nôtres apparaissent ; vie en %.
4. Clic : cibler le boss (liseré blanc) ; clic droit : menu ; survol : infobulle.
5. Le boss incante : barre sous son cadre, nom et temps ; sort qu'on ne peut pas interrompre : gris et cadenas.
6. Tes affaiblissements sur le boss : à gauche de son cadre, avec leur durée ; ceux des autres : non.
7. Marqueur de raid posé sur le boss : en haut à droite.
8. Fin de la rencontre : les cadres partent. Combat : aucune erreur.
9. Couper « Cadres de boss de CœurUI » : nos cadres partent ; /reload : ceux du jeu reviennent.
