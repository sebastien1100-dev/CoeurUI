# Discussion : tests en jeu

## 0.22.0 · première version

1. **Redémarrer le jeu** (nouveaux fichiers). Aucune erreur Lua. `/cui version` : « 0.22.0 ».
2. `/cui` : carte « Discussion » (coupée). L'activer : fond sombre léger, liseré gris fin, plus de décor du jeu.
3. Onglets en petites capitales grises (GÉNÉRAL, JOURNAL...) ; l'onglet ouvert en blanc souligné ; changer
   d'onglet : le soulignement suit.
4. Message de guilde reçu pendant qu'on est sur un autre onglet (onglet Guilde séparé) : pastille rouge sur l'onglet ;
   l'ouvrir : elle disparaît.
5. Canaux : « [G] [Nom] : ... », « [Gr] », « [R] », « [1. Général] [Nom] : ... » (sans la zone), « [2. Commerce] ». Murmures
   inchangés. Heure en gris devant chaque message.
6. Noms des joueurs dans la couleur de leur classe.
7. Message avec une adresse web (ex. https://fr.wowhead.com) : soulignée en bleu clair ; clic : petite fenêtre
   « Lien » avec l'adresse sélectionnée ; Ctrl+C puis coller dans le navigateur. Échap : la fenêtre se ferme.
8. Plus de boutons du jeu (amis, canaux, menu, flèches). Survol de la discussion : deux pictos en haut à droite.
   « Copier la discussion » : grande fenêtre avec les derniers messages, tout sélectionné, la fin visible, molette
   pour remonter. « Descendre en bas » : après avoir remonté (molette), revient aux derniers messages.
9. Attendre la durée réglée sans toucher : les vieux messages s'effacent ; survol : ils reviennent.
10. Cadenas : cadre « Discussion » ; le placer, `/reload` : il est resté. La zone de saisie suit la fenêtre.
11. Page de réglages : largeur, hauteur, taille du texte, opacité (0 : plus de fond), effacement et durée, canaux
    raccourcis (coupé : « [Guilde] », « [1. Général - ...] » reviennent pour les nouveaux messages), couleurs de
    classe, liens, pastille, heure (aucune, 21:05, 21:05:42).
12. Suivi des quêtes : clic droit sur une quête » « Lien Wowhead » : même fenêtre qu'avant, adresse sélectionnée.
13. En combat, en donjon : messages normaux, aucune erreur (le jeu peut cacher certains textes : laissés tels quels).
14. Couper le module : demande un rechargement ; après : la discussion du jeu revient comme avant, avec son heure.
15. Langue anglaise : module « Chat », canaux [G], [P], [R].

## 0.50.0 · style « Givre »

1. **Redémarrer le jeu** (nouvelles textures). Aucune erreur Lua. `/cui version` : « 0.50.0 ».
2. La discussion est posée sur un panneau ardoise au double liseré très discret, coins arrondis, ombre douce.
3. Opacité du fond à 100 : plein ; à 60 : plus léger, liseré net ; à 0 : plus de fond ni de liseré.
4. Saisie au repos (sous la fenêtre) : même fond que la discussion, qui suit l'opacité réglée (à 0 : invisible).
   Appuyer sur Entrée : elle devient une case sombre pleine ; Échap : elle reprend le fond de la discussion.
5. Onglets, pastille, pictos copier / descendre, liens, effacement des vieux messages : comme avant.
6. Onglet « Journal de combat » : même panneau que Général ; la barre « Mes actions / Qu'est-ce qui m'est arrivé ? »
   sans fond noir, posée au-dessus des messages. Une fenêtre détachée (onglet glissé ailleurs) a aussi son panneau.
7. Opacité du fond à 10 : fond à peine visible, seuls les deux liserés fins restent nets autour (coins arrondis
   propres). Même chose sur le suivi des quêtes avec son opacité à 10.
8. Discussion et suivi des quêtes à la même opacité (70) : même teinte, sans ombre autour. À 100 : l'ombre douce
   revient autour des deux.
9. Pictos copier et descendre au-dessus de la discussion, à droite : visibles tout le temps, sans survol.
