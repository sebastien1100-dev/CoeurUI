# Infobulles et menus : tests en jeu

## 0.12.0 · première version

**Avant de commencer** : couper ce qui habille déjà les infobulles et les menus (EllesmereUIBlizzardSkin, s'il le
fait). Le module ne dépend de rien chez EllesmereUI.

1. **Redémarrer le jeu** (nouveau fichier). Aucune erreur Lua. `/cui version` : « 0.12.0 ».
2. Module coupé : survol du cadenas de la fenêtre CœurUI : infobulle sobre (fond sombre, liseré gris fin, titre
   blanc, texte gris clair, plus d'or). Un menu déroulant de CœurUI (ex. Général > Police) : même cadre, choix en
   cours en blanc. Les infobulles du jeu sont encore celles du jeu.
3. Activer « Infobulles et menus ». Survol d'un PNJ : même cadre que celle de CœurUI ; nom coloré selon l'attitude
   (rouge, jaune, vert) ; barre de vie en trait fin juste sous le cadre.
4. Survol d'un objet dans les sacs : même cadre ; nom coloré selon la qualité (vert, bleu, violet...), le reste comme
   d'habitude. Avec Maj (comparaison) : les infobulles de comparaison ont le même cadre.
5. Clic sur un lien d'objet dans la discussion : la fenêtre d'objet a le même cadre.
6. Survol d'un sort de la barre d'actions, d'un bouton du jeu, d'un bouton d'un autre addon : même cadre.
7. Police : Général > Police « Morpheus » : les textes des infobulles du jeu changent. Revenir à Friz Quadrata.
8. **Menus** : clic sur la loupe du suivi (minicarte) : fond sombre, liseré gris ; cases grises, coches blanches ;
   ligne survolée plus claire ; icônes du jeu en couleur à droite ; flèches des sous-menus grises. Ouvrir un
   sous-menu : même style. Clic droit sur un membre du groupe ou sur son portrait : même style.
9. Si un menu garde son style du jeu : `/fstack`, survol du menu, capture d'écran pour Claude.
10. Couper le module : « coupé au prochain /reload ». Après le rechargement : infobulles et menus du jeu comme avant.
11. Langue anglaise : le module s'appelle « Tooltips and menus ».

## 0.17.0 · identifiants

1. `/reload`. Aucune erreur Lua. `/cui version` : « 0.17.0 ».
2. Fenêtre CœurUI : « Tooltips » a maintenant une page : section INFORMATIONS, interrupteur « Afficher les
   identifiants » (activé), avec sa phrase d'explication.
3. Survol d'un sort sur une barre, dans le grimoire, dans les talents : dernière ligne « ID du sort : 12345 » en gris.
4. Survol d'une amélioration ou d'un affaiblissement (sur un cadre d'unité ou les effets du jeu) : « ID du sort : … ».
5. Survol d'un objet dans les sacs, sur le personnage, chez un marchand ; clic sur un lien d'objet dans la discussion :
   « ID de l'objet : 6948 » (par exemple pour la pierre de foyer).
6. En combat : pas d'erreur ; si le jeu cache la valeur, simplement pas de ligne d'ID.
7. Couper « Afficher les identifiants » : les lignes d'ID disparaissent des infobulles suivantes ; le remettre : elles
   reviennent.
8. Langue anglaise : « Show IDs », « Spell ID: … », « Item ID: … ».

## 0.17.1 · sans barre de vie

1. `/reload`. Survol d'un PNJ, d'un joueur, de son propre cadre : l'infobulle n'a plus de barre de vie dessous.
2. Survol d'un joueur (dans le monde ou son cadre) : la ligne de sa classe est dans la couleur de la classe
   (démoniste violet, paladin rose...), la ligne « Alliance » en bleu ou « Horde » en rouge. PNJ : rien ne change.

## 0.18.0 · place des infobulles

1. Module Tooltips actif. Cadenas : un cadre « Infobulles » en bas à droite ; le déplacer en haut à gauche, verrouiller.
2. Survol d'un PNJ dans le monde, d'un cadre d'unité, d'un bouton du micro-menu : l'infobulle s'ouvre en haut à gauche
   et descend. Remettre le cadre en bas à droite : elles s'ouvrent là et montent.
3. Survol d'un sort sur une barre : l'infobulle reste à côté du bouton (pas déplacée).
4. `/reload` : place gardée.
