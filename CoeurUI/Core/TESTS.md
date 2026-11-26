# Noyau : tests en jeu

## Étape 1 · socle (0.1.0)

Avant de commencer : notez la valeur actuelle des plaques des PNJ amis avec
`/dump C_CVar.GetCVar("nameplateShowFriendlyNPCs")` (souvent « 0 »).

1. **Redémarrer le jeu.** Aucune erreur Lua. « CœurUI » apparaît dans la liste des addons.
2. `/cui` affiche l'aide. `/cui version` affiche « version 0.1.0 ».
3. `/cui modules` affiche « • Essai (essai) : coupé ».
4. `/cui activer essai` : « Essai : démarré (1 fois...) », puis 5 s plus tard « minuterie de 5 s terminée ».
   Changer de cible : « Essai : cible changée ».
5. `/dump C_CVar.GetCVar("nameplateShowFriendlyNPCs")` affiche « 1 ».
6. `/reload` : Essai redémarre tout seul, « 2 fois » (le réglage est gardé).
7. `/cui couper essai` : « Essai : arrêté. » Changer de cible : plus de message.
   La valeur des plaques est revenue à celle notée au départ.
8. `/cui activer essai` puis `/cui couper essai` en moins de 5 s : le message de minuterie n'arrive pas.
9. En combat (mannequin d'entraînement) : `/cui activer essai` affiche « en combat : ce sera fait à la sortie
   du combat ». À la sortie du combat, Essai démarre.
10. Essai actif, fermer le jeu, le relancer, puis `/cui couper essai` : les plaques reviennent bien à la valeur
    du départ.
11. `/cui activer truc` : « module inconnu ». `/cui activer` : « précisez le module ». `/cui blabla` : « commande
    inconnue » puis l'aide.
12. `/cui reset` demande confirmation. `/cui reset oui` : Essai s'arrête, « réglages effacés ». `/cui modules`
    demande un /reload. Après `/reload` : Essai coupé ; `/cui activer essai` affiche « 1 fois ».

## Étape 2 · icône et couleurs (0.1.1)

1. **Redémarrer le jeu.** Dans la liste des addons (écran des personnages ou Échap » AddOns), CœurUI a son icône :
   carré graphite à contour doré, C doré, cœur rouge, « UI » blanc. Pas de carré vert ni de point d'interrogation.
2. `/cui version` affiche « version 0.1.1 ». Le « Cœur » du préfixe est doré.

## Étape 3 · fenêtre « Modules » (0.2.0)

À comparer avec la maquette validée. Depuis cette version, `/cui` ouvre la fenêtre et l'aide passe par `/cui aide`.

1. **Redémarrer le jeu.** Aucune erreur Lua. `/cui version` affiche « version 0.2.0 ».
2. `/cui` ouvre la fenêtre : contour doré à coins arrondis, barre de titre avec le logo (C + cœur) et
   « CœurUI · Modules », texte d'introduction, une ligne « Essai », pied avec « 1 module · 0 actif » et « Fermer ».
   `/cui` une deuxième fois la ferme.
3. Survoler la croix : fond plus clair, croix blanche, infobulle « Fermer ». Survoler « Fermer » : contour doré.
   Appuyer sans relâcher : texte doré.
4. Cliquer l'interrupteur d'Essai : il glisse à droite et devient doré, la ligne prend un fond, l'état passe à
   « actif » (vert), le pied affiche « 1 actif ». Les messages d'Essai arrivent dans la discussion.
5. Le recliquer : « coupé », « Essai : arrêté. » dans la discussion.
6. Avec la fenêtre ouverte, taper `/cui activer essai` : la fenêtre se met à jour toute seule. Puis `/cui couper essai`.
7. Déplacer la fenêtre par la barre de titre, la fermer, la rouvrir : elle revient au même endroit. Encore après
   un `/reload`.
8. Fenêtre ouverte, Échap la ferme. Croix et « Fermer » la ferment aussi.
9. En combat (mannequin) : cliquer l'interrupteur. L'état affiche « à la sortie du combat » ; son infobulle
   l'explique. À la sortie du combat, l'état devient « actif » tout seul.
10. `/cui aide` affiche l'aide, avec les deux nouvelles lignes (`/cui` et `/cui aide`).
11. Les accents, « Œ/œ » et « · » s'affichent bien partout ; aucun carré à la place d'une lettre.

## Étape 4 · bouton « Recharger l'interface » (0.3.0)

Pour ces tests, remettre temporairement `needsReload = true` dans `Modules/Essai/Essai.lua` (retiré après la
validation de la 0.3.0), puis redémarrer le jeu.

1. **Redémarrer le jeu.** Aucune erreur Lua. `/cui version` affiche « version 0.3.0 ».
2. `/cui`, activer Essai, puis le couper : l'état passe à « coupé au prochain /reload » (doré), le bouton doré
   « Recharger l'interface » apparaît à gauche de « Fermer ». Essai continue de tourner (« cible changée »).
3. Survoler le bouton : il s'éclaircit, infobulle « Recharger l'interface ».
4. Réactiver Essai : le bouton disparaît, l'état repasse à « actif ». Le recouper : le bouton revient.
5. Déplacer la fenêtre puis survoler le bouton : il réagit toujours à sa nouvelle place (le bouton invisible suit).
6. Fermer la fenêtre (Échap), puis cliquer à l'endroit où était le bouton : **rien ne se passe** (pas de /reload).
7. Rouvrir avec `/cui` et cliquer le bouton : l'interface se recharge, sans message « action bloquée ».
   Après le rechargement : Essai est « coupé », la plaque des PNJ amis est revenue à sa valeur d'origine.
8. En combat (mannequin), fenêtre ouverte avec le bouton visible : le bouton devient gris ; le cliquer ne fait rien ;
   son infobulle dit « Indisponible en combat ». Aucun message « action bloquée ».
9. Toujours en combat : fermer puis rouvrir la fenêtre, la déplacer. Aucun message « action bloquée ».
10. Sortie du combat : le bouton redevient doré et marche de nouveau.
11. En combat, fenêtre fermée, cliquer partout où le bouton a pu être : rien ne se passe.

## Étape 5 · panneau de réglages, curseur, menu déroulant (0.4.0)

À comparer avec la maquette validée (planches « Panneau de réglages » et « Curseur et menu déroulant »).
Essai a maintenant trois réglages pour tester le panneau.

1. **Redémarrer le jeu.** Aucune erreur Lua. `/cui version` affiche « version 0.4.0 ».
2. `/cui` : la ligne d'Essai a un petit bouton « Réglages » entre la description et l'état (même Essai coupé).
3. Cliquer « Réglages » : la fenêtre devient « CœurUI · Essai », avec « « Modules » en haut à gauche, l'état et
   l'interrupteur d'Essai à droite, puis les sections MESSAGES et MINUTERIE. En bas : « Valeurs par défaut » et
   « Fermer ».
4. Activer Essai depuis l'interrupteur du panneau : l'état passe à « actif ». Revenir avec « « Modules » : la liste
   montre aussi Essai actif.
5. Essai actif. Interrupteur « Message au démarrage » : « Essai : réglage « messageDemarrage » = false. »
6. Menu « Message quand la cible change » : il s'ouvre sous le bouton (contour doré, chevron vers le haut), l'option
   choisie est dorée avec un •, l'option survolée a un fond plus clair. Choisir « Long » : la liste se ferme, le
   message de réglage arrive, et changer de cible donne le message long. « Aucun » : plus de message.
7. Ouvrir le menu puis cliquer ailleurs (dans la fenêtre ou hors de la fenêtre) : il se ferme sans rien changer.
   Recliquer sur le menu ouvert le ferme aussi.
8. Curseur « Délai de la minuterie » : le glisser change la valeur en doré (par pas de 1 s) ; la molette sur le
   curseur avance d'un cran ; survol : le bouton s'éclaircit. Un message de réglage à chaque cran.
9. Délai à 2 s, couper puis réactiver Essai : « minuterie de 2 s terminée » arrive après 2 s.
10. « Valeurs par défaut » : interrupteur activé, « Court », 5 s ; un message par réglage changé.
11. `/reload`, rouvrir le panneau : les valeurs choisies sont gardées.
12. Essai coupé : changer un réglage n'écrit rien dans la discussion (le module ne tourne pas), mais la valeur est
    gardée.
13. Échap avec le menu ouvert : fenêtre et menu se ferment. `/cui` rouvre sur la liste.
14. En combat : le panneau s'ouvre, les réglages se changent, aucun message « action bloquée ».

## Étape 6 · fenêtre principale à tiroirs (0.6.0)

À comparer avec les maquettes validées A (tiroirs) et C (accueil). Essai a maintenant deux sous-modules,
« Messages » et « Minuterie », pour tester les tiroirs. Un `/reload` suffit (aucun nouveau fichier).

1. `/reload`. Aucune erreur Lua. `/cui version` affiche « version 0.6.0 ».
2. `/cui` : fenêtre plus grande. À gauche, sur fond plus sombre : « Tous les modules » (choisi, doré), un trait,
   puis « Bouton de minicarte » et « Essai » avec une pastille (verte si actif, grise si coupé). Essai a un
   chevron « > ».
3. À droite, l'accueil : « Tous les modules », le texte d'aide, une carte par module (nom, description,
   interrupteur). La carte d'un module actif a un fond plus clair. Essai a un lien « Réglages » ».
   Le pied indique « 2 modules · n actifs ».
4. Interrupteur d'une carte : le module s'active ou se coupe, la pastille de gauche change de couleur.
5. Cliquer « Essai » à gauche : le tiroir s'ouvre (chevron vers le bas), « Messages » et « Minuterie » apparaissent
   en retrait ; « Messages » est choisi (doré, trait doré à gauche). À droite : « Essai » en petit, « Messages » en
   titre, l'état et l'interrupteur d'Essai, puis les réglages. Le titre de la fenêtre devient « CœurUI · Essai ».
6. Cliquer « Minuterie » : sa page s'ouvre (curseur). Recliquer « Essai » : le tiroir se ferme, la page reste.
7. Essai actif : changer un réglage écrit « Essai : réglage « messages / cible » = long. » (ou minuterie / delai).
   Les réglages marchent comme avant (messages de cible, délai de la minuterie après un arrêt / redémarrage).
8. « Valeurs par défaut » ne remet à zéro que la page ouverte.
9. « Bouton de minicarte » à gauche : sa page dit « Ce module n'a pas de réglages. », avec l'interrupteur ;
   pas de « Valeurs par défaut ».
10. Carte « Essai » de l'accueil, lien « Réglages » » : ouvre le tiroir sur « Messages ».
11. Molette sur la colonne de gauche ou la zone de droite : rien ne bouge tant que tout tient (pas de barre).
    Menu déroulant ouvert, molette : le menu se ferme.
12. Fermer et rouvrir la fenêtre : elle revient sur l'accueil, à la même place à l'écran.
13. Le coin bas gauche de la fenêtre reste arrondi (la colonne sombre ne dépasse pas du contour).
14. En combat : tout marche (sauf « Recharger l'interface », grisé), aucun message « action bloquée ».

## Étape 7 · page « Paramètres », langue, bouton de minicarte (0.7.0)

À comparer avec les maquettes validées « Paramètres » et « Settings (anglais) ». Le bouton de minicarte n'est
plus un module : c'est un réglage de la page « Paramètres ».

1. **Redémarrer le jeu** (nouveaux fichiers et nouvelle texture). Aucune erreur Lua. `/cui version` : « 0.7.0 ».
2. Le bouton de minicarte est toujours là, **à la même place qu'avant** (sa place est reprise de l'ancien module).
   Clic : la fenêtre s'ouvre ; glisser : il tourne autour de la minicarte ; infobulle « CœurUI ».
3. Fenêtre : « Bouton de minicarte » n'est plus dans la liste des modules ni dans l'accueil. En bas de la colonne
   de gauche, sous un trait : engrenage + « Paramètres ».
4. Cliquer « Paramètres » : doré ; à droite « Paramètres », le texte d'aide, un trait, puis LANGUE (menu
   « Langue de CœurUI » avec la note dessous) et MINICARTE (interrupteur « Bouton de minicarte »). Pied :
   « Valeurs par défaut » et « Fermer ».
5. Le menu de langue propose « Langue du jeu (Français) », « Français », « English ».
6. Décocher « Bouton de minicarte » : le bouton disparaît tout de suite. Recocher : il revient au même endroit.
   `/reload` : le choix est gardé.
7. Choisir « English » : le bouton doré « Recharger l'interface » apparaît. Revenir sur « Langue du jeu » : il
   disparaît. Remettre « English » et cliquer le bouton.
8. Après le rechargement, tout CœurUI est en anglais : titre « CœurUI · Modules », « All modules », « Settings »,
   module « Test » avec ses sous-modules « Messages » et « Timer », réglages, infobulles, pied (« Close »,
   « Reset to defaults »). `/cui help` : l'aide en anglais. `/cui enable essai`, `/cui disable essai` marchent ;
   `/cui activer essai` aussi.
9. Activer « Test » : ses messages dans la discussion sont en anglais (« Test: started... »).
10. Remettre « Langue du jeu (Français) », recharger : tout repasse en français.
11. « Valeurs par défaut » sur la page Paramètres : langue du jeu, bouton de minicarte affiché.
12. `/cui reset oui` puis `/reload` : le bouton de minicarte est affiché, la langue est celle du jeu.
13. Aucun texte ne s'affiche sous forme de clé en majuscules (par exemple « ESSAI_NOM ») ; aucun carré à la place
    d'une lettre, en français comme en anglais.

## Étape 8 · cadenas, mode déplacement, pages sur deux colonnes (0.8.0)

Le module « Essai » est supprimé : les étapes plus haut qui s'en servent ne se refont plus telles quelles.
Le mode déplacement, les pages sur deux colonnes, l'aperçu fourni par un module et le menu de textures n'ont
pas encore de module qui s'en sert : ils seront testés avec le module « Cadres d'unité ».

1. **Redémarrer le jeu** (nouveaux fichiers et nouvelles textures). Aucune erreur Lua. `/cui version` : « 0.8.0 ».
2. Si Essai était actif avant la mise à jour : la plaque des PNJ amis est revenue à sa valeur d'origine
   (`/dump C_CVar.GetCVar("nameplateShowFriendlyNPCs")`).
3. `/cui` : la colonne de gauche n'a plus que « Tous les modules » et « Paramètres ». L'accueil dit « Aucun
   module. », le pied « 0 module · 0 actif ». `/cui modules` : « aucun module. »
4. Barre de titre : un cadenas fermé, gris pâle, à gauche de la croix. Survol : infobulle « Déverrouiller les
   cadres » avec « Aucun cadre à déplacer : activez un module qui en a. ». Clic : rien ne se passe.
5. En combat : l'infobulle du cadenas dit « Indisponible en combat. ». Aucun message « action bloquée ».
6. Page « Paramètres » : inchangée (langue, bouton de minicarte), tout marche comme avant.
7. Barre de titre : « v0.8.0 » en petit et en gris, à gauche du cadenas.
8. « Paramètres » non choisi : pas de trait doré à gauche ; choisi : fond plus clair, texte et engrenage dorés.
