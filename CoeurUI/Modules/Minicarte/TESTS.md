# Bouton de minicarte : tests en jeu

## 0.5.0 · première version

1. **Redémarrer le jeu.** Aucune erreur Lua. Le bouton rond (C + cœur, contour doré) est au bord de la minicarte,
   en bas à gauche.
2. Survol : le bouton s'éclaircit légèrement, infobulle « CœurUI » avec « Clic » et « Glisser ».
3. Clic : la fenêtre « Modules » s'ouvre ; second clic : elle se ferme.
4. Glisser le bouton : il tourne autour de la minicarte en suivant la souris, sans s'en éloigner. Le relâcher
   ailleurs, faire `/reload` : il est resté à sa nouvelle place.
5. `/cui` : la ligne « Bouton de minicarte » est « actif ». Couper l'interrupteur : le bouton disparaît tout de
   suite, sans /reload. Le réactiver : il revient à la même place.
6. Couper le module, `/reload` : le bouton n'apparaît pas. Le réactiver depuis `/cui` : il apparaît.
7. Si la minicarte est carrée (autre addon de minicarte) : le bouton suit le bord du carré, coins compris.
8. En combat : clic et glisser marchent, aucun message « action bloquée ».
9. Rangé dans la grille d'un addon de minicarte (EllesmereUIMinimap) : le rond est entier, contour doré visible
   tout autour. Le clic ouvre la fenêtre ; le glisser est géré par cet addon, plus par CœurUI.
