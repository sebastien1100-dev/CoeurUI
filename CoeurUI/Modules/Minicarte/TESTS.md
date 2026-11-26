# Minicarte : tests en jeu

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
