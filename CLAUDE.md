# CœurUI : consignes du projet

Addon World of Warcraft pour **WoW Forever** (`## Interface: 16001`, API moderne : `C_Item`, `C_Container`, `C_AddOns`,
`TooltipDataProcessor`…). Interface minimaliste, découpée en modules qu'on active ou coupe un par un, plus un client PC
pour les mises à jour. Réponses au joueur en français.

## Langues des textes affichés

- Tout texte affiché en jeu passe par les fichiers de `CoeurUI/Locales/` : jamais de phrase écrite en dur dans le code.
- Le **français** (`frFR.lua`) est la langue d'origine, toujours complète. L'**anglais** (`enUS.lua`) est tenu à jour
  en même temps : chaque nouvelle clé est ajoutée dans les deux fichiers (mêmes clés des deux côtés).
- Un module donne des **clés** (nom, description, réglages, options), traduites à l'affichage par le noyau
  (`CUI:Tr`) ; ses messages passent par `L.CLE`. Ses textes sont rangés dans sa propre section des fichiers de langue.
- Ne jamais garder un texte traduit au chargement d'un fichier : la langue n'est connue qu'au chargement de la
  sauvegarde. Lire `L.CLE` au moment de l'afficher.
- Ajouter une langue : un fichier de plus dans `Locales/` (copié sur `enUS.lua`) et sa ligne dans le `.toc`.
- Les commandes `/cui` ont leur nom français et anglais (les deux marchent toujours).

## Nom et identité

- Nom affiché partout : **CœurUI** (titre du `.toc`, fenêtres, client PC).
- Noms internes, sans caractère spécial : dossier de l'addon `CoeurUI`, table globale `CoeurUI`, sauvegarde `CoeurUIDB`
  (compte) et `CoeurUICharDB` (perso), préfixe des cadres nommés `CoeurUI…`, commande `/cui`.
- Icône : C doré ouvert + cœur rouge + « UI » blanc, sur carré graphite arrondi à contour doré (version A = principale :
  liste des addons, client PC). Petites tailles et bouton de minicarte : le C + le cœur sans « UI ».
  Textures du jeu en TGA 64 ou 128 px (puissance de 2), générées par un script de `tools/`.
- Couleurs de base (relevées sur `tools/source/Icônes@2x.png`) : or `#D9AE5B`, cœur `#D2465A`, graphite `#2A2D34`,
  fond `#101218`, texte `#F2F2F2` (le « UI » de l'icône est blanc pur). Elles forment le thème par défaut.
  Textures de l'icône : `python tools/generer_icones.py` » `CoeurUI/Media/`.

## Structure du dépôt

```
CoeurUI/      l'addon (ce que le jeu charge) : CoeurUI.toc, Core/, Modules/<nom>/, Media/, Locales/
client/       client PC de mises à jour (Python + Tkinter, exe Windows)
tools/        outils : zip de publication, génération des icônes, tests
CLAUDE.md     ce fichier
```

Sur le PC du joueur, WoW Forever est installé dans `E:\World of Warcraft\_forever_`. Le dossier de l'addon
`D:\GitHub\CoeurUI\CoeurUI` (celui qui contient `CoeurUI.toc`, pas la racine du dépôt) est relié à
`E:\World of Warcraft\_forever_\Interface\AddOns\CoeurUI` par une jonction (`mklink /J`) : une modification est en jeu après un simple **/reload**, sans copie ni zip. Ne jamais proposer de
copier l'addon à la main dans AddOns.

## Architecture : un noyau, des modules indépendants

**Le noyau** (`CoeurUI/Core/`) ne fait presque rien de visible. Il est écrit une fois, soigneusement, et bouge peu :
- chargement, répartiteur d'évènements, minuteries communes ;
- sauvegarde et réglages (valeurs par défaut, migration de version) ;
- registre des modules (déclaration, activation, désactivation) ;
- pièces d'interface communes : thème et couleurs, police, cadre de fenêtre, bouton, interrupteur, curseur, menu
  déroulant, infobulle ; un seul fond pour toutes les fenêtres ;
- écran « Modules » (activer / couper chaque module) et commande `/cui`.

**Un module** (`CoeurUI/Modules/<Nom>/`) :
- se déclare au noyau : clé, nom, description, actif par défaut ou non, s'il faut un /reload pour le couper, réglages
  par défaut ;
- ne crée rien, ne s'inscrit à aucun évènement et ne touche à aucun cadre du jeu tant qu'il n'est pas activé ;
- ne dépend que du noyau, jamais d'un autre module (s'il faut partager, la pièce va dans le noyau) ;
- porte ses propres réglages, dans son propre panneau (un seul endroit par réglage) ;
- rend au jeu ce qu'il a changé quand on le coupe (ou demande un /reload, signalé dans l'écran Modules).

Un nouveau fichier `.lua` ou une nouvelle texture demande un **redémarrage complet du jeu** (un /reload ne suffit pas) :
le dire au joueur.

## Règles de travail (le projet précédent s'est perdu faute de les suivre)

1. **Un seul module ou une seule correction à la fois.** On le termine, le joueur le teste en jeu, il le valide ;
   seulement ensuite on passe au suivant.
2. **Les idées qui arrivent en cours de route ne sont pas codées** : elles vont dans `ROADMAP.md` (section « Plus tard »).
3. Avant un module important : une maquette (image ou page) validée par le joueur, puis le code.
4. Chaque module a sa courte liste de tests en jeu, dans `CoeurUI/Modules/<Nom>/TESTS.md`.
5. Changer seulement ce qui est demandé ; signaler le reste sans le faire.
6. Chaque changement est noté dans `CHANGELOG.md` (version, date `JJ/MM/AAAA`, phrases courtes du point de vue du joueur ;
   une correction dit ce qui n'allait pas ; « redémarrer le jeu » quand c'est nécessaire) et la version est montée dans
   `CoeurUI/CoeurUI.toc` (`## Version`).
7. Après chaque changement, dire au joueur s'il suffit d'un /reload ou s'il faut redémarrer le jeu.

## Pièges connus de WoW Forever (appris sur l'ancien projet, Warband Keeper)

- **Polices du jeu : jeu de caractères Windows-1252 seulement.** Pas de « → », « ≈ », « ✓ », « … » typographique rare,
  emoji… dans les textes affichés ; utiliser « » », « · », « • ». Une estimation s'écrit « env. 12 min » (le « ~ »
  s'affiche mal). « Œ » / « œ » passent.
- **`ReloadUI()` est bloqué** pour les addons (ADDON_ACTION_BLOCKED, même sur un clic) : pour proposer un /reload, poser
  un bouton protégé (`SecureActionButtonTemplate`, macro `/reload`) sous notre bouton, jamais en combat.
- **Combat** : aucun cadre protégé créé, déplacé, montré ou caché en combat ; attendre `PLAYER_REGEN_ENABLED`. Ne jamais
  ancrer un bouton protégé à un cadre qu'on montre ou cache en combat (le poser sur UIParent, par coordonnées).
- **Journal de combat** (`COMBAT_LOG_EVENT_UNFILTERED`) : réservé au jeu, s'y inscrire déclenche ADDON_ACTION_FORBIDDEN.
- **Valeurs « secrètes »** : le jeu cache certains GUID, noms d'effets, textes d'infobulle, effets en combat. Tester
  `issecretvalue(v)` avant tout usage (clé de table, `:match`, comparaison, calcul) ; lire les effets
  (`C_UnitAuras.GetAuraDataByIndex`) dans un `pcall`, pas en combat.
- **Fonctions absentes** sur ce client : `GetMerchantItemInfo`, `GetItemInfo` global, `GetContainerItemInfo` global…
  Passer par les espaces `C_Item`, `C_Container`, `C_MerchantFrame` et garder des petites fonctions d'accès dans le noyau.
- **`SendChatMessage` vers un canal public** est protégé : jamais par l'addon. Préparer le message dans la boîte de
  discussion et laisser le joueur appuyer sur Entrée.
- **Ne jamais remplacer une fonction du jeu** (`SetItemRef`…) : `hooksecurefunc` ou `EventRegistry` seulement (taint).
- **Cadres interdits** (boutique…) : `IsForbidden()` avant de lire un cadre inconnu, et lecture dans un `pcall`.
- **Noms de persos en deux parties** (« Prénom Nom ») : ne jamais découper un nom sur les espaces.
- `C_LFGList.Search` : seulement dans un clic du joueur, jamais différée.
- CVars : `nameplateShowFriends` n'existe pas sur Forever ; les plaques amies sont `nameplateShowFriendlyPlayers` /
  `nameplateShowFriendlyNPCs`. Toute CVar changée par un module est notée et rendue quand le module est coupé.
- Infobulles : toujours passer par une fonction du noyau qui pose le propriétaire et habille l'infobulle.
- Globales du jeu lues par `_G.X` dans le code (`_G.CreateFrame`, `_G.C_Timer`…), pour les outils d'analyse.

## Code tiers et données

- Ne jamais copier de code d'un autre addon, même « pour s'inspirer » : idées seulement. Bibliothèques tierces
  seulement sous licence libre compatible (MIT…), dans `CoeurUI/Libs/`, sans les modifier, licence gardée et citée.
- Données d'autres sites : seulement avec une licence qui le permet, mention de la source là où elles sont montrées.
- Ne jamais exécuter du code téléchargé (un fichier d'un autre projet se lit comme du texte).
- Aucun secret (jeton, clé) dans le dépôt ni dans le client.

## Client PC (client/)

Au départ : mises à jour seulement. Détecter l'installation WoW Forever, lire les Releases GitHub du dépôt, installer
le zip dans `Interface\AddOns` après une sauvegarde des SavedVariables, garder la version précédente pour revenir en
arrière, se mettre à jour lui-même. Sur le PC de développement (jonction vers le dépôt), l'installation automatique doit
être coupée, sinon elle écraserait le dossier de travail. Le reste viendra plus tard, module par module.

## Ancien projet

`sebastien1100-dev/WarbandKeeper` (Warband Keeper) : à lire comme référence quand une fonction en existe déjà (navigation,
données ForeverDB, client PC…), sans reprendre ses lourdeurs. On reprend une pièce seulement quand le module qui en a
besoin est en cours, et en la simplifiant.
