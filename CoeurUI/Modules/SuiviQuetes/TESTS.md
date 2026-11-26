# Suivi des quêtes : tests en jeu

## 0.18.0 · première version

**Avant de commencer** : couper **EllesmereUIQuestTracker** dans la liste des addons (il change lui aussi le suivi).
Le module ne dépend de rien chez EllesmereUI. Avoir quelques quêtes suivies, dont une avec une barre de progression.

1. **Redémarrer le jeu** (nouveau fichier). Aucune erreur Lua. `/cui version` : « 0.18.0 ».
2. Activer « Suivi des quêtes ». Le suivi passe à droite, sous la minicarte, sans le décor du jeu : titres de section
   gris, titres de quête colorés (gris, vert, jaune, orange, rouge selon le niveau), objectifs gris clair, objectif
   fait en vert avec sa coche. Fond sombre léger derrière les quêtes seulement.
3. Barre de progression (objectif bonus, pourcentage) : fine, gris clair sur fond graphite.
4. Clic gauche sur une quête : le journal s'ouvre sur elle. Maj + clic : lien dans la discussion. Clic droit : le menu
   du jeu avec, en bas, « Lien Wowhead ».
5. « Lien Wowhead » : petite fenêtre CœurUI, titre avec le nom de la quête, adresse `https://fr.wowhead.com/quest=…`
   sélectionnée. Ctrl+C puis coller dans le navigateur : la page de la quête s'ouvre. Taper dans la case : l'adresse
   revient. « Sélectionner » : la re-sélectionne, message « Sélectionnée : appuyez sur Ctrl+C. ». Échap ou « Fermer » :
   la fenêtre se ferme.
6. Page de réglages : largeur (le suivi s'élargit, les textes passent sur moins de lignes), hauteur maximale (au-delà,
   le suivi défile), tailles des titres et des objectifs (le suivi se réarrange sans chevauchement).
7. Fond : décocher (plus de fond) ; opacité 100 % puis 0 % ; recocher.
8. Repli : « Replier en combat » coché : à l'entrée en combat, le suivi se replie ; à la sortie, il se déplie. Entrer
   dans un donjon (repli en donjon coché par défaut) : replié ; sortir : déplié. Replier le suivi à la main hors donjon :
   il reste replié.
9. Cadenas : « Suivi des quêtes » a son contour doré (largeur × hauteur maximale) et se place. `/reload` : place gardée.
10. Couper le module : « coupé au prochain /reload ». Après le rechargement : le suivi du jeu comme avant.
11. Langue anglaise : « Quest tracker », « Wowhead link », adresse `www.wowhead.com`.
12. Plus de ligne « Tous les objectifs » en haut du suivi (ni son bouton) ; le suivi commence à « Quêtes ». Le fond
    entoure les quêtes avec la même marge des quatre côtés, icônes des quêtes comprises ; il suit quand une quête
    s'ajoute ou se termine, et quand une section se replie.
13. Objectifs : 0/8 en rouge, 4/8 en jaune, 7/8 presque vert, 8/8 vert ; barre « 62 % » : jaune-vert. Une quête
    terminée : « À rendre » en vert. Une ligne sans nombre d'une quête en cours : gris clair.
