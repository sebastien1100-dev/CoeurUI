# Minicarte : tests en jeu

## 0.64.0 · taille des points

1. Page Minicarte : curseur « Taille des points » à 100 % ; le baisser à 60 % : les points de la carte
   (groupe, PNJ, objectifs) rapetissent tout de suite ; le remonter : ils reviennent.
2. /reload : la taille choisie est gardée.

## 0.10.0 · première version

**Avant de commencer** : couper **EllesmereUIMinimap** dans la liste des addons (il change lui aussi la minicarte).
Le module ne dépend de rien chez EllesmereUI.

1. **Redémarrer le jeu** (nouveaux fichiers et nouvelles textures). Aucune erreur Lua. `/cui version` : « 0.10.0 ».
2. `/cui` : carte « Minicarte » (coupé) dans l'accueil, et son entrée à gauche.
3. Activer le module. La minicarte devient un carré de 220, en haut à droite, avec un liseré sombre (pas d'or),
   sans la bordure ronde, la boussole, les boutons + / -, l'heure ni le calendrier.
4. **Nom de la zone** au-dessus de la carte, coloré : vert en zone amicale, rouge hostile, orange contestée, bleu
   en sanctuaire. Il change quand on change de zone ou de sous-zone.
5. **Coordonnées** centrées en bas de la carte, sur un voile sombre ; elles bougent quand on marche. En donjon :
   rien (ni texte ni voile).
6. **Zoom à la molette** sur la carte. Décocher « Zoom à la molette » : la molette ne zoome plus.
7. **Boutons du jeu** : suivi en haut à droite (clic : menu de suivi). Courrier en haut à gauche, seulement avec du
   courrier en attente (survol : expéditeurs). File d'attente en bas à gauche, seulement en file (clic : état de la
   file). Bannière de difficulté en haut de la carte, en instance.
8. **Tiroir** : petit bouton à quatre carrés sous la carte, à droite. Clic : la grille des boutons d'addons s'ouvre
   (dont le bouton de CœurUI s'il est affiché) ; chaque bouton marche comme avant. Second clic, ou clic ailleurs :
   le tiroir se ferme. Plus aucun bouton d'addon autour de la carte.
9. Décocher « Ranger les boutons des addons dans un tiroir » : le bouton du tiroir disparaît et les boutons des
   addons reviennent autour de la carte (au pire, à leur place après un /reload).
10. **Taille** : largeur 300, « Garder un carré » coché : carré de 300, la hauteur est grisée. Décocher, hauteur 180 :
    rectangle 300 × 180 ; le terrain, la flèche du joueur et les points (quêtes, groupe) restent dans le rectangle ;
    zoomer : le terrain ne glisse pas. Essayer aussi une carte haute (largeur 160, hauteur 320).
11. **Cadenas** : la carte, le nom de la zone, le courrier, le suivi, la file et le tiroir ont chacun leur contour
    doré. Déplacer la carte : les autres éléments la suivent. Déplacer le nom de la zone, le tiroir, un bouton :
    chacun reste à sa nouvelle place, puis `/reload` : rien n'a bougé. Clic droit sur un élément : sa place
    d'origine.
12. « Remettre les éléments autour de la carte » (réglages) : le nom, le tiroir et les boutons reviennent autour de
    la carte ; la carte, elle, ne bouge pas.
13. Couper chacun des interrupteurs « Nom de la zone », « Coordonnées », « Boutons du jeu » : l'élément disparaît
    tout de suite, et revient quand on le recoche.
14. Couper le module : « coupé au prochain /reload » et bouton « Recharger l'interface ». Après le rechargement, la
    minicarte du jeu est revenue telle quelle (ronde, boutons, heure, calendrier).
15. Langue anglaise (Paramètres) puis rechargement : module « Minimap », réglages et étiquettes du cadenas en anglais.

## 0.10.1 · icônes CœurUI et tiroir sans doublon

1. **Redémarrer le jeu** (nouvelles textures). `/cui version` : « 0.10.1 ».
2. Suivi : loupe au trait gris clair dans son petit carré sombre ; blanche au survol ; clic : menu de suivi du jeu.
3. Courrier en attente : enveloppe avec une pastille rouge ; survol : expéditeurs. Sans courrier : rien.
4. En file d'attente : oeil au trait ; clic : état de la file. Hors file : rien.
5. Bouton du tiroir : icône à quatre carrés au trait, blanche au survol.
6. Tiroir ouvert : chaque addon une seule fois ; plus de bouton « 3 ». Polestar (sans bouton à lui) y a son icône ;
   clic dessus : comme dans le menu des addons du jeu.
7. Plus aucun texte ni décor de l'ancienne minicarte sous la carte (ex. les coordonnées en double).
8. Cadenas ouvert : glisser l'étiquette « Suivi » (ou « Courrier », « File d'attente », « Tiroir des addons »,
   « Nom de la zone ») : seul cet élément bouge, pas la carte. L'étiquette s'éclaircit au survol ; clic droit
   dessus : place d'origine. L'étiquette « Minicarte » est sous la carte, à gauche ; la glisser déplace la carte et
   tous ses éléments.
9. Cadres d'unité : glisser leur étiquette les déplace aussi (comme avant en glissant le cadre).

## 0.11.0 · sans infobulles

1. `/reload`. Survol de l'icône du courrier (avec du courrier), du suivi et du tiroir : l'icône devient blanche, mais
   aucune infobulle n'apparaît. Les clics marchent toujours (menu de suivi, tiroir).

## 0.12.0 · tiroir sans doublon (suite)

1. Tiroir ouvert : chaque addon une seule fois (Forever Bestiary Pet Hunter, Naowh... : seulement leur bouton rond,
   plus de copie carrée). Les addons sans bouton à eux (Polestar...) ont toujours leur icône carrée ; survol : leur
   nom ; clic : comme dans le menu des addons du jeu.
2. Rester 1 minute en jeu puis rouvrir le tiroir : toujours pas de doublon (un addon qui crée son bouton en retard
   fait disparaître la copie).
3. Cadenas : poser le bouton du tiroir sur la carte, verrouiller. Clic dessus : le tiroir s'ouvre (la carte ne
   prend plus le clic).
4. Clic sur le tiroir : la grille s'ouvre à gauche de la carte (carte à droite de l'écran), alignée sur le bas de la
   carte ; carte déplacée à gauche de l'écran : la grille s'ouvre à sa droite. Cadre : fond sombre, liseré gris fin,
   coins à peine arrondis (comme les infobulles).
5. Tiroir ouvert : tous les boutons ont le même rond (même taille, fond graphite, liseré gris fin), sans leurs anciens
   anneaux dorés ou bleus ; l'image de chaque addon est gardée, découpée en rond. Survol : le liseré s'éclaircit,
   l'infobulle de l'addon s'affiche ; clic : l'addon réagit comme avant.
6. Installer (ou activer) un autre addon qui a un bouton de minicarte, redémarrer : il arrive dans le tiroir avec le
   même rond.
7. Décocher « Ranger les boutons des addons dans un tiroir » : les boutons reviennent autour de la carte avec leur
   habit d'origine.

## 0.18.0 · menu du suivi

1. Clic sur la loupe du suivi : le menu s'ouvre à gauche de la carte (carte à droite de l'écran), son haut aligné sur
   le haut de la carte. Déplacer la carte à gauche de l'écran (cadenas) : le menu s'ouvre à sa droite.
2. Contour de la carte : un trait noir puis un trait graphite, d'un pixel chacun, réguliers sur les quatre côtés,
   coins nets ; pareil après avoir changé l'échelle de l'interface (options du jeu) puis /reload.

## 0.51.0 · style « Givre »

1. `/reload`. Aucune erreur Lua. `/cui version` : « 0.51.0 ».
2. La carte est entourée du panneau du thème (double liseré très discret, coins arrondis, ombre douce) ; la carte
   reste carrée dedans. Rectangle (réglage) : pareil.
3. Bouton de suivi, courrier (quand il y en a), file d'attente (en file), tiroir : petites cases sombres ; survol :
   icône blanche, liseré doré (ou couleur de la classe). Courrier : pastille rouge cœur.
4. Tiroir ouvert : cadre des fenêtres, titre « ADDONS » en haut à gauche, ronds des addons dessous ; survol d'un
   rond : liseré de la couleur des boutons. Tiroir vide : le message seul.
5. Coordonnées en bas de la carte dans une petite case sombre.
