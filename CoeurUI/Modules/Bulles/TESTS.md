# Bulles de discussion : tests en jeu

## 0.32.0

1. **Redémarrer le jeu** (nouveau fichier). Aucune erreur Lua. `/cui version` : « 0.32.0 ».
2. `/cui` : carte « Bulles de discussion » (coupée) ; l'activer.
3. Options du jeu : bulles de discussion affichées. En ville, près d'un PNJ qui parle (ou `/dire bonjour`) :
   bulle au fond sombre, liseré gris fin, coins à peine arrondis, pas d'or ; pointe au même style (fond sombre, liseré gris) vers celui qui parle.
4. Texte à la police de CœurUI ; `/dire` en blanc, `/crier` en rouge, PNJ en couleur du jeu.
5. Réglage « Taille du texte » : la prochaine bulle (ou celle affichée) change de taille, le fond suit le texte.
6. Réglage « Opacité du fond » : le fond (et la pointe) laissent voir le décor.
7. Couper « Couleur du texte selon le canal » : tout le texte des bulles en gris clair.
8. En groupe, `/groupe salut` : bulle au même style.
9. Dans un donjon : bulles du jeu, aucune erreur.
10. Couper le module : /reload demandé ; après : bulles du jeu.

## 0.53.0 · style « Givre »

1. `/reload`. Aucune erreur Lua. `/cui version` : « 0.53.0 ».
2. Dire quelque chose (/dire) : bulle au fond ardoise, double liseré très discret, coins arrondis ; pointe dessous
   au liseré sombre, sans trait à la jonction.
3. Opacité 60 : fond plus léger, liseré net, pointe aussi légère que le fond.
4. Crieur de Hurlevent, groupe : couleur du texte selon le canal (réglage) ; coupé : gris clair.
