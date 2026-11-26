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
