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
