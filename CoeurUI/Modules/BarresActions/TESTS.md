# Barres d'actions : tests en jeu

## 0.14.0 · étape 1 : barres 1 à 8

**Avant de commencer** : couper **EllesmereUIActionBars** dans la liste des addons (il remplace lui aussi les
barres du jeu). Le module ne dépend de rien chez EllesmereUI. Ne pas ouvrir le mode Édition du jeu pendant le test.

1. **Redémarrer le jeu** (nouveau fichier). Aucune erreur Lua. `/cui version` : « 0.14.0 ».
2. Activer « Barres d'actions ». Les barres du jeu disparaissent ; barres 1 et 2 en bas au centre, 3 et 4 en colonnes
   à droite. Carrés à liseré gris fin, icônes rognées, sans le cadre du jeu. Les sorts sont ceux des barres du jeu.
3. Raccourcis : chaque touche lance le sort de son bouton (barre 1 : 1 à =, et ceux des barres 2 à 4). La touche est
   écrite en petit en haut à droite.
4. Survol : liseré plus clair et infobulle du sort. Clic : lance le sort. Glisser un sort du grimoire sur un
   emplacement vide : il s'y pose ; glisser un sort hors de la barre : il s'enlève (hors combat).
5. Recharge : voile qui tourne avec les secondes. Hors de portée (cibler loin) : icône rouge. Sans assez de
   ressource : icône bleutée. Charges : nombre en bas à droite. Sort mis en avant (proc) : halo blanc.
6. Barre 1 qui change de page : forme du druide (ours, félin), furtivité du voleur, véhicule, Maj + molette ou
   Maj + 2 : les sorts de la page s'affichent et les raccourcis les lancent.
7. Page de réglages : menu « Barre ». Choisir Barre 3 : les réglages montrent ceux de la barre 3. Nombre 6, par
   rangée 3, sens Verticale : la vraie barre et l'aperçu changent (2 colonnes de 3). Taille, espacement : idem.
8. Visibilité : « Au survol seulement » : la barre disparaît, réapparaît quand la souris passe dessus ; l'opacité
   est grisée. « En combat seulement » : visible seulement en combat. « Jamais » : cachée, ses raccourcis
   reviennent aux boutons du jeu. Opacité 50 % : à moitié transparente hors survol.
9. Textes : couper Raccourci, Charges ; activer Nom des macros : la barre suit.
10. Réglage changé en combat : appliqué à la sortie du combat, sans message « action bloquée ».
11. Cadenas : chaque barre a son contour doré et son nom ; la glisser (grille aimantée). `/reload` : places gardées.
12. Barres 5 à 8 : cochées « Afficher cette barre » : elles apparaissent au centre, prêtes à être placées.
13. « Valeurs par défaut » : seule la barre choisie dans le menu revient à ses réglages d'origine.
14. Couper le module : « coupé au prochain /reload ». Après le rechargement : barres du jeu comme avant.
15. Langue anglaise : « Action bars », « Bar 1 (main) ».
