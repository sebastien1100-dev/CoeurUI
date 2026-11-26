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
