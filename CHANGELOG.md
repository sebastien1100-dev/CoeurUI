# CœurUI : notes de version

La plus récente en premier. Phrases courtes, du point de vue du joueur.

## 0.64.0 · 28/11/2026

- Minicarte : nouveau réglage « Taille des points » (de 50 à 100 %) pour les points du groupe, des PNJ et des
  objectifs ; plus petits, la carte respire en ville. Leur dessin, lui, ne peut pas changer sur Forever.

## 0.63.0 · 28/11/2026

- Skin Blizzard : les talents au style « Givre » (maquette « 3 · Talents »), avec leur interrupteur sur la
  page du module. L'illustration de classe du jeu est gardée, estompée, sur une case ardoise ; plus de cadre
  doré, de séparations ni de grande barre orangée.
- En-tête de chaque arbre : icône carrée en case, points dépensés en petite case, nom en gras.
- Talents : icône carrée en case ; indisponible gris et sombre ; disponible au liseré gris clair ; en partie
  au liseré vert ; au maximum au liseré blanc ; survol au liseré doré. Rang pris (maquette « 3 bis ») :
  pastille sous l'icône, « 1/5 » en vert en cours, « 5 » en blanc complet. Liens en traits fins,
  plus clairs quand ils sont ouverts.
- Haut : onglets « PRINCIPALE » et « SECONDAIRE » (le verrouillé grisé avec notre cadenas), « Talents
  restants » et son nombre dans une case (vert quand il en reste), recherche et suggestions de CœurUI.
- Bas : « Appliquer changements » et les autres boutons de CœurUI.
- Fiche du personnage (chasseur) : le quatrième petit onglet, celui du familier, était une case vide ; il a
  notre empreinte de patte, et la toile ne reste plus allumée quand il est ouvert.
- Fiche, page du familier (chasseur) : le titre jaune débordait de la fenêtre ; il tient sur une ligne
  centrée, « Crocilisque niveau 24 · Niveau de loyauté 6 · Meilleur ami », la famille en blanc, le reste en
  gris. Humeur (maquette « 1 quater ») : un cœur dans une petite case, plein et vert (heureux), à moitié
  et jaune (content), vide, fêlé et rouge (mécontent). Barre d'expérience striée verte dans une case.
- Discussion : l'heure est entre crochets suivie d'un tiret, « [21:05] - », toujours en gris discret ; elle prenait parfois la
  couleur du message (le jeu réécrivait son format sans couleur) : remise toutes les 2 secondes si besoin.
- `/cui cadre Cadre.Partie` : relève une pièce sans nom global.
- Redémarrer le jeu (nouveau fichier).

## 0.62.0 · 28/11/2026

- Skin Blizzard : le grimoire au style « Givre » (maquette « 2 · Grimoire »), avec son interrupteur sur la
  page du module. Cadre de CœurUI (plus de portrait, de métal ni de boutons rouges), croix et « agrandir »
  au trait, page rappelée à gauche du titre, déplaçable par son bandeau.
- Catégories en petites cases à icône carrée ; recherche dans une case sombre ; page en case ardoise, titre
  en gras sur un trait.
- Sorts : icône carrée dans une case du thème, nom blanc, sous-titre gris ; passifs un peu ternes ; survol au
  liseré doré ; sort absent des barres d'actions : pastille rouge cœur ; sort à choix : petit chevron.
- « Page 1/1 », flèches en petites cases (grisées sur une seule page) ; onglets Talents et Grimoire en
  petites capitales.
- Recherche du grimoire : case sombre, croix « effacer » au trait ; suggestions dans le panneau des menus
  de CœurUI, sans le fond ni la lueur bleue du jeu.
- `/cui cadre 5` : relève le cadre sous la souris dans 5 secondes (le temps d'ouvrir un menu qui se ferme
  quand on tape dans la discussion).
- Redémarrer le jeu (nouveau fichier, nouvelles icônes).

## 0.61.0 · 28/11/2026

- Fiche du personnage, page Monnaies au style « Givre » : sections repliables, monnaies avec leur icône
  dans une petite case, nom gris clair, quantité blanche, bande plus claire au survol, défilement fin.
- Détail : titre en gras, trait sombre, textes gris ; cases « Inutilisée » et « Montrer dans le sac » et
  bouton « Transférer » de CœurUI.
- Journal des transferts : cadre des fenêtres de CœurUI au lieu du cadre métallique, croix grise.
- Sections repliables (réputation, compétences, statistiques, monnaies) : le chevron passe à gauche, devant
  le nom, comme sur la maquette (il restait à la place du « - » du jeu, à droite).
- Monnaies : la description restait blanche ; elle est en gris clair.
- Toutes les pages de la fiche du personnage sont habillées.
- Redémarrer le jeu (nouveau fichier).

## 0.60.0 · 28/11/2026

- Fiche du personnage, page JcJ au style « Givre » (maquette « 1 ter ») : le blason de faction du jeu est
  gardé, posé dans un médaillon rond du thème (plus d'anneau doré ni de cercle de progression) ; rang chiffré
  en petite case ; « Points de rang » en barre striée de la couleur de la faction, avec ce qui manque pour le
  rang suivant (ou « Rang maximum atteint ») ; saison en petites capitales, rang en gras.
- Détail : titre en gras, textes gris, intertitre « RÉCOMPENSES AU RANG » en petites capitales sur un trait,
  récompense en case d'objet du thème.
- Redémarrer le jeu (nouveau fichier).

## 0.59.0 · 28/11/2026

- `/cui cadre` sautait tout cadre dont le nom contenait « RankFrame » (page JcJ vide) : seules les pièces
  qui portent exactement ce nom sont sautées.
- Fiche du personnage, page Statistiques au style « Givre » : sections repliables (chevron, petites
  capitales) ; sous-sections (« Boss »...) : le « + » / « - » rouge devient une petite case avec notre
  chevron, leur nom en blanc ; lignes : nom en gris clair, valeur en blanc, bande plus claire au survol ;
  défilement fin.
- Redémarrer le jeu (nouveau fichier).

## 0.58.0 · 28/11/2026

- Fiche du personnage, page Compétences au style « Givre » : sections repliables (chevron, petites
  capitales), compétences en gris clair, barres striées gris bleuté dans une case, ligne survolée ou choisie
  sur une bande plus claire, défilement fin ; détail à droite : nom en gras, traits sombres, même barre,
  description en gris clair ; intertitres du détail (« Contre les boss de raid »...) en petites capitales
  grises sur un trait sombre, au lieu du bandeau doré.
- Barres dont la couleur est dessinée dans l'image du jeu (bleu des compétences...) : notre barre striée
  prend cette couleur (elle restait blanche).
- Redémarrer le jeu (nouveau fichier).

## 0.57.0 · 28/11/2026

- Fiche du personnage, page Réputation au style « Givre » : sections repliables avec notre chevron et des
  petites capitales ; factions en gris clair ; barres striées dans une case, de la couleur de l'attitude ;
  ligne survolée ou choisie sur une bande un peu plus claire ; défilement fin.
- Détail de la faction : nom en gras, attitude en gris, traits sombres, même barre, description en gris
  clair ; cases à cocher de CœurUI (coche au trait, libellé gris, plus de jaune).
- Redémarrer le jeu (nouveau fichier).

## 0.56.0 · 28/11/2026

- Fiche du personnage, page Personnage : les cases d'équipement sont carrées (le jeu les fait en 37 x 36,
  l'icône n'était pas carrée) ; une case vide est unie (le dessin pâle de l'emplacement a disparu, l'infobulle
  le nomme toujours).
- Cases d'équipement survolées : liseré doré (or clair quand on appuie), comme les boutons des barres
  d'actions.
- La fiche se déplace : la prendre par son bandeau de titre ; elle garde sa place d'une ouverture à
  l'autre.
- Sacs, banque et fiche : les icônes d'objet avaient les coins arrondis (le jeu remettait l'image entière,
  avec son liseré arrondi) ; elles sont carrées, toujours rognées.
- Résistances : l'icône du jeu gardait son cadre brun ; elle est remplacée par notre icône au trait, une
  forme par école (étoile des arcanes, flamme, flocon, feuille, croissant de lune), dans une petite case.
- Les trois petits onglets du haut ne réagissaient pas au survol (deux passaient pour ouverts) : un seul
  ouvert à la fois, survol comme les onglets de côté.
- Les pieds du personnage dépassaient de sa case : l'aperçu prend maintenant la taille de la case.
- Gestionnaire d'ensembles : les flèches jaunes à côté des cases deviennent de petites cases avec notre
  chevron ; le petit menu de choix d'une pièce perd son cadre doré et le liseré jaune de la case ouverte
  (panneau du thème, choix en cases du thème). Bouton « Nouvel ensemble » : « + » au trait et texte gris
  clair au lieu du vert, sur une ligne, à la largeur des boutons « Équiper » et « Sauver ». Boutons spéciaux
  du menu (« Mettre dans les sacs », « Ignorer l'emplacement ») : nos icônes au trait (sac et flèche, cercle
  barré).
- Redémarrer le jeu (nouvelles icônes).
- Le titre de la fiche restait jaune et changeait selon la page (« Comp. »...) : c'est toujours le nom du
  personnage, en blanc ; la page est rappelée à gauche.

## 0.55.0 · 28/11/2026

- Fiche du personnage (Skin Blizzard), suite de la maquette « fiche complète » : nos icônes au trait sur les
  onglets de côté (personnage, réputation, compétences, JcJ, monnaies, statistiques) et sur les boutons du
  personnage (zoom, rotation, retour) ; plus d'or : onglet ouvert et case survolée au liseré gris clair.
- « Guerrier de niveau 6 » : la classe en blanc, le reste en gris (plus de jaune du jeu). Le nom de la page
  ouverte est rappelé en petites capitales à gauche du titre.
- Le fond sombre du personnage couvrait toute la colonne de gauche, cases comprises : il est maintenant
  posé entre les deux colonnes d'équipement.
- Redémarrer le jeu (nouvelles icônes).

## 0.54.0 · 28/11/2026

- Nouveau module « Skin Blizzard » : les fenêtres du jeu habillées au style de CœurUI, une à une, sur une seule
  page, avec un interrupteur par fenêtre. Première fenêtre : la fiche du personnage.
- Fiche du personnage au style « Givre » : cadre ardoise sans portrait ni décor doré, croix grise ; personnage sur
  un fond sombre et ses boutons en petites cases ; cases d'équipement du thème (liseré de la qualité, case vide
  très pâle) ; statistiques en sections à petites capitales, une ligne sur deux plus claire, défilement fin ;
  onglets de côté en cases (l'ouvert au liseré de la couleur des boutons). Rien ne bouge, seul l'aspect change.
- Fiche : les objets communs n'ont plus de liseré blanc (liseré de qualité à partir de « Peu commun », comme
  dans les sacs) ; les trois petits onglets en haut des statistiques et la case des munitions au même style
  (la case des munitions gardait son cadre doré et sa flèche orange : retirés). Les trois petits
  onglets du haut ont nos icônes au trait (toile des caractéristiques, cuirasse des ensembles, trois traits des titres), à la place de celles du jeu et
  de leur cadre brun. Icônes des résistances
  dans une petite case du thème, sans leur cadre brun.
- Nouvelle commande `/cui cadre [nom]` (`/cui frame`) : les pièces d'un cadre du jeu, à copier (outil pour habiller
  les fenêtres suivantes).
- Redémarrer le jeu (nouveaux fichiers).

## 0.53.0 · 28/11/2026

- Bulles de discussion au style « Givre » : le cadre des infobulles (fond ardoise, double liseré très discret,
  coins arrondis) et une pointe au même liseré sombre. L'opacité réglée éclaircit le fond, le liseré reste net.
- Bulles un peu moins hautes (le cadre du jeu laissait beaucoup de marge au-dessus et au-dessous du texte).
- Un /reload suffit.

## 0.52.0 · 28/11/2026

- Effets au style « Givre » : chaque amélioration et chaque affaiblissement dans une case du thème (fond sombre,
  double liseré discret, coins arrondis) avec une ombre douce. Les affaiblissements gardent le liseré de la
  couleur de leur type.
- Un /reload suffit.

## 0.51.1 · 28/11/2026

- Fenêtre de CœurUI : le bouton « Fermer » en bas est retiré (la croix en haut à droite et Échap ferment la
  fenêtre) ; « Valeurs par défaut » prend sa place.
- Un /reload suffit.

## 0.51.0 · 28/11/2026

- Minicarte au style « Givre » : la carte est posée dans le panneau du thème (double liseré très discret, coins
  arrondis, ombre douce), elle reste carrée dedans.
- Courrier, suivi, file d'attente et bouton du tiroir : petites cases du thème ; au survol, icône blanche et
  liseré de la couleur des boutons.
- Tiroir des addons au cadre des fenêtres, avec le titre « ADDONS » ; ronds des addons sur fond de case, liseré
  de la couleur des boutons au survol.
- Coordonnées dans une petite case sombre.
- Un /reload suffit.

## 0.50.0 · 28/11/2026

- Discussion au style « Givre » : les messages sont posés sur le panneau du thème (fond ardoise, double liseré très
  discret, coins arrondis, ombre douce). L'opacité réglée éclaircit le fond et l'ombre, le liseré reste net ; à 0,
  plus de fond du tout.
- Zone de saisie : au repos, exactement le fond de la discussion (même panneau, même opacité réglée) ; quand on
  tape, une case sombre pleine pour bien lire. Le décor gris du jeu qui restait dessous est retiré.
- Journal de combat (et toute autre fenêtre de discussion) : même panneau que l'onglet Général (il n'avait pas de
  fond) ; sa barre de filtres (« Mes actions »...) perd le fond noir du jeu.
- Fond transparent (discussion, suivi des quêtes) : à faible opacité, le fond restait presque opaque (les
  liserés étaient des rectangles pleins posés dessous) ; les liserés sont maintenant de vrais contours. Fond
  transparent : plus d'ombre dessous (elle l'assombrissait : à réglage égal, le suivi des quêtes paraissait plus
  noir que la discussion) ; l'opacité réglée est celle qu'on voit, la même partout.
- Les pictos « copier » et « descendre en bas » au-dessus de la discussion restent toujours visibles (ils
  n'apparaissaient qu'au survol).
- Nouveau réglage dans « Général » : opacité du fond de la fenêtre de CœurUI (de 20 à 100 %) ; le fond et sa
  colonne s'éclaircissent, textes, cartes et boutons restent nets.
- Redémarrer le jeu (nouvelles textures).

## 0.49.0 · 28/11/2026

- Plaques de nom au style « Givre » : barres de vie et d'incantation dans une case sombre au double liseré discret,
  coins arrondis, couleur unie à fines stries en diagonale. Pas d'ombre (plus léger avec beaucoup de plaques).
- Menace : le liseré extérieur passe en orange ou rouge cœur, comme avant ; sinon il est sombre.
- Mes affaiblissements au-dessus du nom : cases du thème.
- Un /reload suffit.

## 0.48.0 · 28/11/2026

- Suivi des quêtes au style « Givre » : la liste est posée sur le panneau du thème (fond ardoise, double liseré
  très discret, ombre douce). Le réglage d'opacité du fond éclaircit le fond et l'ombre, le liseré reste net.
- Traits sombres sous l'en-tête et sous la zone dépliée (gris léger quand le fond est coupé).
- Quête suivie sur la carte posée sur une carte un peu plus claire aux coins arrondis (au lieu du voile blanc) ;
  survol d'une quête : la même carte, plus discrète.
- Objets de quête en cases du thème ; survol de la couleur des boutons.
- Le reste du suivi du jeu (campagne, objectifs bonus...) a le même cadre, sous notre liste.
- Un /reload suffit.

## 0.47.0 · 28/11/2026

- Sacs et banque au style « Givre » : fenêtres ardoise au double liseré très discret avec une ombre douce, titre
  fondu dans le fond, traits sombres sous le titre et au-dessus du bas, recherche dans une case du thème.
- Cases comme les boutons des barres d'actions : fond sombre et double liseré discret ; le liseré prend la couleur
  de la qualité à partir de « Peu commun » ; survol : liseré de la couleur des boutons. Emplacements de sac pareils.
- Chaque catégorie affiche son nombre de cases (« ÉQUIPEMENT · 5 ») ; le niveau d'objet prend la couleur de la
  qualité.
- Un /reload suffit.

## 0.46.0 · 28/11/2026

- Infobulles et menus au style « Givre » : fond ardoise presque opaque (la teinte des fenêtres), double liseré très
  discret, coins de 4 points et ombre douce, à la place du fond noir au liseré gris. Toutes les infobulles du jeu et
  ses menus (clic droit...) avec le module « Infobulles et menus », et celles de CœurUI dans tous les cas.
- Menus : on voyait une fraction de seconde le menu du jeu (à l'ouverture, au survol d'une ligne, en ouvrant un
  sous-menu) avant qu'il prenne le style de CœurUI ; il est habillé tout de suite.
- Menus : la ligne survolée s'éclaire plus doucement. Menus déroulants de CœurUI : ligne survolée et choix en cours
  aux teintes du thème.
- Un /reload suffit.

## 0.45.0 · 28/11/2026

- Barres d'actions au style « Givre » : chaque barre est posée sur un panneau ardoise avec une ombre douce, les
  boutons sont des cases du thème au double liseré discret. Nouveau réglage par barre « Barre posée sur un
  panneau » : coupé, les boutons sont posés seuls, chacun avec sa petite ombre.
- Survol d'un bouton : liseré de la couleur des boutons (or ou couleur de la classe, réglage de « Général »),
  plus clair au clic. Même style pour le micro-menu, les sacs, le familier, les postures et « Quitter le véhicule ».
- Hors de portée : voile rouge cœur.
- Barres d'expérience et de réputation : fines stries en diagonale, fond et liseré du thème.
- Barre des postures : la posture ou forme active a un liseré permanent de la couleur des boutons.
- Barre des postures : son panneau a la taille des postures connues (il gardait la place de 10 boutons).
- Places par défaut des barres un peu écartées pour laisser la place aux panneaux (les barres déjà placées au
  cadenas ne bougent pas).
- Un /reload suffit.

## 0.44.1 · 28/11/2026

- Barres d'incantation : un sort sans nom traduit s'affichait « Opening - No Text » (ouvrir un coffre, un sac de
  récolte...) ; il s'affiche « Ouverture ». Les autres sorts de ce genre perdent juste « - No Text ».
- Un /reload suffit.

## 0.44.0 · 28/11/2026

- Fenêtre de CœurUI au style « Givre » : fond ardoise bleutée, double liseré très discret et ombre douce à la place
  du contour doré ; barre de titre fondue dans le fond ; colonne de gauche et cartes des modules aux teintes du
  thème. L'or reste sur le logo, le choix en cours, les interrupteurs et le bouton principal.
- Même style pour les petites fenêtres de CœurUI (lien Wowhead...).
- Nouveau réglage dans « Général » : couleur des survols et boutons (interrupteurs, curseurs, choix en cours),
  l'or de CœurUI ou la couleur de ta classe. Appliquée après un /reload (bouton proposé). Le « Cœur » du titre reste
  doré.
- Un /reload suffit.

## 0.43.0 · 28/11/2026

- Nouveau style de CœurUI, « Givre » (direction artistique validée) : fond ardoise bleutée, double liseré très
  discret, ombre douce sous les cadres, coins de 4 points, barres à fines stries en diagonale.
- Premiers servis : les cadres d'unité (joueur, cible, cible de la cible, familier, groupe, boss), leurs barres
  d'incantation et leurs effets. Les autres modules suivront un par un.
- Nouvelle texture de barre « Striée (CœurUI) », celle d'office ; la texture lisse choisie jusqu'ici passe aux
  stries une fois (on peut la remettre dans Cadres d'unité › Général).
- Plaques de nom : plus de « ! » à côté des monstres de quête : leur barre de vie prend une couleur à choisir
  (jaune d'office ; orange, violet, bleu, vert, rose). L'avancement (« 5/10 ») est à gauche de la barre, de la
  même couleur, avec sa propre taille (Plaques de nom › Ennemis › Quêtes).
  Un monstre de quête déjà pris par un autre joueur a sa barre en gris (il ne compterait pas pour toi).
- Suivi des quêtes : le surlignage de la quête suivie sur la carte et l'anneau de sa pastille étaient coupés à
  gauche ; plus de parenthèses vides après le nom d'un monstre (« Vermine kobold () »).
- Redémarrer le jeu (nouveaux fichiers).

## 0.42.0 · 28/11/2026

- Suivi des quêtes, troisième étape (finitions, chacune réglable dans la section Affichage) :
- Nombre de quêtes en tête (« Quêtes · 19/40 » : dans le journal sur le maximum ; « · 17 suivies » si toutes ne
  le sont pas) ; le « – »
  replie tout, « + » déplie.
- Distance à droite du titre (« 120 m »), mise à jour en marchant.
- Clic sur la pastille d'une quête : elle est suivie sur la carte (flèche et point du jeu) ; elle se démarque par
  un fond plus clair et un anneau blanc autour de sa pastille.
- Au-delà de 2 quêtes à rendre dans une zone, les autres se rangent sous « N autres quêtes à rendre », qui se
  déplie d'un clic.
- Sortes de quêtes en petits pictos au trait derrière le titre, à la place de « (Élite) »... : couronne (élite),
  porte (donjon), crâne (raid), deux silhouettes (groupe, avec le nombre conseillé).
- Redémarrer le jeu (nouvelles icônes).

## 0.41.0 · 28/11/2026

- Suivi des quêtes, deuxième étape : les objets de quête. Leur bouton est à droite de leur quête, avec ses
  charges et sa recharge ; un clic utilise l'objet, survol : son infobulle.
- Le bouton se pose hors combat ; en combat il reste utilisable à sa place. Un objet qui apparaît en combat, ou
  une liste qui bouge en combat : le bouton suit à la fin du combat.
- Un /reload suffit.

## 0.40.1 · 28/11/2026

- Suivi des quêtes : un trait léger souligne le titre d'une zone dépliée (80 % de la largeur du fond).
- Un /reload suffit.

## 0.40.0 · 28/11/2026

- Suivi des quêtes : notre propre liste à la place des quêtes du suivi du jeu (première étape). Quêtes rangées par
  zone, dans l'ordre du journal, la zone où tu es en premier (« ici ») ; titres de zone repliables d'un clic
  (gardés d'une session à l'autre) ; quêtes à rendre en premier. « Ne déplier que ma zone » (actif d'office) : les
  autres zones restent repliées, un clic en ouvre une jusqu'au prochain changement de zone.
- Même style qu'avant : titre à la couleur de la difficulté, (Donjon), (Élite) ; avancée en début de ligne,
  rouge » jaune » vert ; « À rendre ».
- Clic : la quête dans le journal ; Maj-clic : son lien dans la discussion ; clic droit : ouvrir, ne plus suivre,
  partager, lien dans la discussion, chercher un groupe (« LFG [quête] », en anglais, prêt dans la discussion),
  lien Wowhead, abandonner.
- Il grandit vers le bas jusqu'à la hauteur maximale, puis défile à la molette (le titre de la zone en cours reste
  en haut). Le reste du suivi du jeu (campagne, objectifs bonus...) s'affiche dessous, au même style (réglage).
- Les boutons d'objets de quête viendront à l'étape suivante.
- Redémarrer le jeu (nouvelle icône).

## 0.39.0 · 27/11/2026

- Suivi des quêtes : l'avancée des objectifs en début de ligne (« 0/12 Glande à venin d'Aile-fière »), réglage
  « Avancée en début de ligne » (actif d'office). « personnages tués » est retiré (« 3/8 Récupérateur
  gueule-de-dragon ») ; une autre précision reste entre parenthèses.
- Suivi des quêtes : le réglage « Trier par zone » est retiré : il ne faisait rien, le jeu impose lui-même
  l'ordre des quêtes suivies.
- Un /reload suffit.

## 0.38.0 · 27/11/2026

- Suivi des quêtes : réglage « Trier par zone, la mienne en premier » (actif d'office). Les quêtes suivies sont
  rangées zone par zone, dans l'ordre du journal, celles de la zone où tu te trouves en haut ; l'ordre suit quand
  tu changes de zone ou de quêtes (hors combat).
- Suivi des quêtes : il défile à la molette quand il y a plus de quêtes que sa hauteur (réglage « Faire défiler à
  la molette », actif d'office ; pas en combat). Avant, les quêtes en trop étaient cachées.
  Pendant le défilement, le titre de la section (« Quêtes »...) reste fixé en haut ; clic dessus : la replier.
  Le fond garde alors toute la hauteur du suivi et ne bouge pas : seule la liste glisse dedans.
- Suivi des quêtes : changer sa hauteur l'allonge vers le bas ; il grandissait vers le haut.
- Un /reload suffit.

## 0.37.0 · 27/11/2026

- Cadres d'unité : cadres de boss (page « Boss »). Jusqu'à 5 boss en colonne à droite de l'écran, au style de la
  cible, à la place de ceux du jeu ; vie en pourcentage, marqueur de raid, liseré blanc sur le boss ciblé.
- Barre d'incantation sous chaque boss (grise avec un cadenas si on ne peut pas l'interrompre) ; mes
  affaiblissements à gauche du cadre, avec leur durée.
- Cadenas ouvert : 5 boss d'exemple pour placer et régler les cadres.
- Soins à venir aussi sur les cadres du joueur, de la cible, de la cible de la cible et du familier (réglage dans
  « Général » de Cadres d'unité, actif d'office).
- Redémarrer le jeu (nouveau fichier).

## 0.36.0 · 27/11/2026

- Cadres de groupe : option « Familiers détachés ». Les familiers quittent le dessous de leur maître pour une
  colonne à part, placée librement avec le cadenas (cadre « Familiers du groupe »).
- Familiers sous leur maître : la place n'est plus gardée sous les équipiers qui n'en ont pas (hors combat ; en
  combat, quand le groupe change, le jeu range les cadres avec une place sous chacun jusqu'à la fin du combat).
- Un /reload suffit.

## 0.35.0 · 27/11/2026

- Cadres de groupe, troisième étape : les familiers. Un petit cadre (nom, vie) sous chaque équipier qui a un
  familier, toi compris ; clic : le cibler, clic droit : son menu. Réglage « Familiers des équipiers ».
- En colonne, la place d'un familier est gardée entre deux cadres. Le groupe de test montre ceux du chasseur et du
  démoniste.
- Un /reload suffit.

## 0.34.0 · 27/11/2026

- Cadres de groupe, deuxième étape : les effets (section « Effets » de la page « Groupe »).
- Soins à venir : la vie se prolonge en vert clair pendant qu'un soin arrive sur l'équipier.
- Mes soins sur la durée (liseré vert) et affaiblissements à dissiper (liseré de leur type : magie bleu,
  malédiction violet, poison vert, maladie brun), en petites icônes en bas à droite du cadre, avec leur durée.
- « Seulement ceux que ma classe dissipe » (actif d'office) ; nombre d'effets au plus et taille des effets.
- Place des affaiblissements et des soins sur la durée, chacun la sienne : un coin du cadre ou le centre
  (d'office : affaiblissements au centre, soins en bas à droite). Le nombre au plus vaut pour chaque sorte.
- Taille des icônes réglable à part pour les affaiblissements et pour les soins sur la durée.
- Un équipier qui a un affaiblissement à dissiper : le liseré de son cadre prend la couleur de l'affaiblissement
  (réglable, actif d'office), avec un trait de 1 point de cette couleur juste sous le contour et un léger voile sur le cadre.
- Correction : les soins à venir ne s'affichaient pas (barre accrochée avant que la barre de vie ait sa texture).
- Le groupe de test (cadenas ouvert) montre des effets d'exemple.
- Correction : erreur « Font not set » en ouvrant le cadenas (texte du nombre d'effets créé sans police).
- Fenêtre de CœurUI, page « Tous les modules » : cartes plus basses, toutes visibles sans défiler ; plus de lien
  « Réglages » : un clic sur la carte ouvre ses réglages (liseré plus clair au survol).
- Sacs : le sac de composants (emplacement à part, après les quatre sacs) est rangé à part en bas, comme les
  autres sacs de composants ; il se mêlait aux sacs ordinaires.
- Sacs et banque : bouton « Trier » dans la barre de titre de chacun (le tri du jeu).
- Redémarrer le jeu (nouvelle icône).

## 0.33.0 · 27/11/2026

- Cadres d'unité : cadres de groupe, première étape (page « Groupe »). Un cadre par membre, toi compris (réglable),
  au style du cadre du joueur, à la place de ceux du jeu.
- Colonne ou ligne, dans les quatre sens ; tri par rôle (tank, soigneur, dégâts), ordre du groupe, nom ou classe.
- Rôle en icône au trait, ressource, chef, marqueur de raid ; cadre pâli hors de portée ; « Mort », « Fantôme »,
  « Déconnecté » ; liseré blanc sur la cible, rouge sur qui a la menace.
- Cadenas ouvert : un groupe de test animé pour placer et régler les cadres, même seul.
- Correction : erreur à la création des cadres de groupe (« attempt to call a nil value »).
- Redémarrer le jeu (nouveaux fichiers).

## 0.32.0 · 27/11/2026

- Nouveau module « Bulles de discussion » (coupé d'office) : les bulles au-dessus des personnages au style des
  infobulles (fond sombre, liseré gris fin), avec une pointe au même style. Réglages : taille du texte, opacité du fond, couleur
  du texte selon le canal.
- Dans les donjons et les raids, le jeu verrouille les bulles : elles y restent les siennes.
- Couper le module demande un rechargement.
- Redémarrer le jeu (nouveau fichier).

## 0.31.0 · 27/11/2026

- Sacs et banque : la banque, dans le même style et le même rangement que les sacs, s'ouvre à gauche des sacs
  chez le banquier. Les sacs s'ouvrent avec elle.
- En bas de la banque : ses emplacements de sac débloqués (glisser un sac dessus) et « Acheter un emplacement »
  avec son prix.
- Recherche commune : taper dans l'une filtre les deux fenêtres. Le rangement (catégories ou vrac) et les
  emplacements affichés se règlent à part pour chaque fenêtre ; réglage « Banque par catégories » (section Banque).
- Fermer la banque (croix ou Échap) quitte le banquier ; les sacs restent ouverts. Elle se déplace en glissant sa
  barre de titre, ou au cadenas.
- Réglage « Banque au style de CœurUI » (section Banque) : coupé, on retrouve la banque du jeu.
- Le bouton tiroir de la banque affiche ses propres emplacements (il montrait ou cachait ceux des sacs) ; les
  emplacements encore verrouillés portent un cadenas, cliquer le premier l'achète (prix dans l'infobulle).
- Redémarrer le jeu (nouvelle icône).

## 0.30.0 · 27/11/2026

- Sacs : vente de la camelote. Chez un marchand, bouton « Vendre » avec le prix sur la section Camelote (en vrac :
  au-dessus de la grille) ; le total vendu s'écrit dans la discussion.
- Réglage « Vendre la camelote » : bouton chez le marchand, toute seule en ouvrant un marchand, ou jamais.
- Un /reload suffit.

## 0.29.0 · 27/11/2026

- Nouveau module « Sacs et banque » (coupé d'office), première étape : tous les sacs dans une seule fenêtre sobre,
  à la place de ceux du jeu, placée au cadenas.
- Rangement par catégories (équipement, consommables, composants, quêtes, divers, camelote, places libres) ou en
  vrac (réglage). Sacs de composants et carquois à part, en bas, avec leurs places libres.
- Cases au liseré de la couleur de la qualité, niveau d'objet sur l'équipement, pastille rouge sur les nouveaux
  objets jusqu'au survol.
- Recherche par nom ; en bas : sacs équipés (cliquer ou glisser pour les changer), places libres, argent.
- La fenêtre se déplace en glissant sa barre de titre (ou avec le cadenas) ; sa place est gardée.
- Places libres : carrés sombres au liseré à peine visible ; le dessin de sac vide du jeu (aile brune) ne
  s'affiche plus.
- Bouton dans la barre de titre des sacs pour passer du rangement par catégories au vrac, et retour.
  Redémarrer le jeu (nouvelle icône).
- Bouton « tiroir » dans la barre de titre : affiche ou cache les emplacements de sac en bas (choix gardé).
- Clics, glisser, infobulles et utilisation des objets : comme le jeu. Couper le module demande un rechargement.
- Redémarrer le jeu (nouveaux fichiers).

## 0.28.0 · 27/11/2026

- Plaques de nom : nouvelle page « Amis ». Les plaques des PNJ et joueurs alliés montrent le nom seul, vert pour un
  PNJ, couleur de classe pour un joueur ; une barre fine apparaît quand l'allié est blessé.
- En donjon et en raid, le jeu garde les plaques amies pour lui : elles restent les siennes.
- Réglages : habiller ou non, barre quand l'allié est blessé, niveau devant le nom des joueurs (coupé d'office), taille du nom,
  largeur et hauteur de la barre.

## 0.27.0 · 27/11/2026

- Plaques de nom : l'incantation des ennemis sous leur barre de vie, avec le nom du sort et le temps restant. Bleu
  acier (vert pour une canalisation) ; grise avec un petit cadenas si on ne peut pas l'interrompre ; rouge un instant
  quand elle est interrompue.
- Réglages : afficher ou non, hauteur.
- Plaques de nom : l'avancement d'une quête se lit comme dans le journal (« 0/8 » au début, « 5/8 » ensuite) ; il
  affichait ce qu'il restait à faire, à l'envers du journal.
- Plaques de nom : en groupe, les monstres de vos quêtes sont de nouveau signalés (le « ! » disparaissait dès qu'on
  était en groupe).

## 0.26.0 · 27/11/2026

- Plaques de nom : vos affaiblissements au-dessus du nom des ennemis, en petits carrés au liseré gris fin, temps
  restant dessous. Ils avaient disparu avec la première étape (les icônes du jeu étaient cachées avec sa plaque).
- Réglages : afficher ou non, taille, nombre au plus.
- Plaques de nom : les marqueurs de raid (crâne, croix...) reviennent, à droite de la barre. Ils avaient disparu avec
  la première étape.

## 0.25.0 · 27/11/2026

- Nouveau module « Plaques de nom » (coupé d'office), première étape : les plaques ennemies au style de CœurUI.
  Barre de vie fine, liseré gris fin, nom au-dessus avec le niveau en petit gris devant (« 35+ » pour une élite),
  pourcentage de vie dans la barre.
- Couleur d'attitude (hostile rouge, neutre jaune, gris si le monstre est pris par un autre), couleur de classe pour
  un joueur adverse.
- La plaque de la cible est plus grande (125 %, réglable).
- Menace sur le liseré : orange quand ça bascule, rouge cœur quand il y a danger (selon le rôle, pris de la
  spécialisation ou réglé).
- Monstre de quête : nom en jaune, « ! » jaune à gauche, ce qu'il reste à faire dessous.
- Les plaques amies restent celles du jeu pour l'instant. Couper le module demande un rechargement.
- Redémarrer le jeu (nouveau fichier).

## 0.24.0 · 27/11/2026

- Barres d'actions : nouvelle page « Expérience et réputation ». Deux barres fines au style de CœurUI à la place de
  celles du jeu, chacune avec son propre cadre au cadenas.
- Expérience en violet, puis en jaune celle des quêtes terminées à rendre, puis le bonus de repos en bleu.
  « +1 niveau » s'affiche à droite quand les quêtes à rendre font passer un niveau.
- Réputation suivie dans la couleur de son rang. Clic dessus : la page des réputations.
- Texte au-dessus des barres au survol (ou toujours, ou jamais), infobulle avec le détail.
- Réglages : largeur et hauteur de chaque barre, taille du texte, quêtes à rendre, repos, infobulle.
- Redémarrer le jeu (nouveau fichier).

## 0.23.0 · 27/11/2026

- Nouveau module « Effets » (coupé d'office) : les améliorations et affaiblissements du joueur en carrés sobres
  (icône rognée, liseré gris fin), le temps restant dessous en petit gris clair (blanc sous 10 secondes), le nombre
  d'applications en bas à droite.
- Affaiblissements avec un liseré de la couleur de leur type (magie, malédiction, poison, maladie).
- Améliorations et affaiblissements indépendants : chacun son cadre au cadenas et sa page de réglages (taille, par
  rangée, rangées au plus, espacement, sens, textes).
- Changer la taille des effets ne déplace pas le groupe : il reste collé du côté d'où partent les icônes.
- Clic droit pour annuler une amélioration et infobulles : comme le jeu. Couper le module demande un rechargement.
- Redémarrer le jeu (nouveau fichier).

## 0.22.0 · 27/11/2026

- Nouveau module « Discussion » (coupé d'office) : la discussion du jeu au style sobre de CœurUI. Fond sombre
  léger réglable, liseré gris fin ; onglets en petites capitales grises, l'onglet ouvert en blanc souligné ; pastille
  rouge sur un onglet qui reçoit un message.
- Canaux raccourcis ([G], [Gr], [R], [1. Général] au lieu de [1. Général - zone]), heure en gris discret (aucune, 21:05 ou 21:05:42), noms en couleur de
  classe.
- Liens web soulignés : un clic ouvre une petite fenêtre avec l'adresse prête à copier (Ctrl+C).
- Boutons du jeu autour de la discussion retirés ; au survol, deux petits pictos : « Copier la discussion » (les
  derniers messages en texte, prêts à copier) et « Descendre en bas ».
- Vieux messages effacés au bout d'un temps réglable ; ils reviennent au survol.
- Placée avec le cadenas ; largeur, hauteur, taille du texte réglables. Couper le module demande un rechargement.
- La fenêtre « Lien Wowhead » du suivi des quêtes est maintenant celle du noyau (même aspect).
- Redémarrer le jeu (nouveaux fichiers).

## 0.21.0 · 27/11/2026

- Barres d'actions : le temps de recharge des sorts s'affiche en secondes sur les boutons (police de CœurUI). Option
  « Temps de recharge (en secondes) » dans les textes de chaque barre, du familier et des postures (activée d'office).
- Les chiffres sont ceux du jeu (son option « nombres de recharge », mise en marche par CœurUI tant qu'une barre les
  demande, rendue quand plus aucune n'en veut ou quand le module est coupé). Ils peuvent aussi apparaître sur
  d'autres recharges du jeu (objets des sacs...).
- Barres d'actions : plus d'animation d'incantation sur les boutons (remplissage pendant le sort, éclair rouge
  d'interruption, cible au sol) ; l'incantation se lit sur la barre d'incantation.
- Un /reload suffit.

## 0.20.0 · 27/11/2026

- Cadres d'unité : nouvelle barre d'incantation de la cible, sous son cadre et à sa largeur, comme celle du joueur.
  Bleue quand on peut interrompre le sort, grise avec un petit cadenas quand on ne peut pas ; verte pour une
  canalisation ; rouge « Interrompu » quand le sort est coupé. Pas de zone de latence.
- Elle suit la cible : changer de cible montre tout de suite le sort que la nouvelle cible incante.
- Option « Détacher du cadre » : placée seule avec le cadenas (au centre de l'écran par défaut), à sa propre largeur.
- Réglages dans la page « Cible », section « Barre d'incantation », sans aperçu.
- Si le jeu cache le temps du sort de la cible en combat : la barre avance sans chiffres (ou reste pleine).
- Le cadre de la cible de la cible suit maintenant le cadre de la cible : juste dessous, ou sous sa barre
  d'incantation quand elle y est attachée. Sa place est remise à zéro une fois : le replacer avec le cadenas si besoin.
- Un /reload suffit.

## 0.19.1 · 27/11/2026

- Suivi des quêtes : la fenêtre « Lien Wowhead » n'a plus de bouton « Sélectionner » (l'adresse est déjà
  sélectionnée) ; un clic dans l'adresse la garde sélectionnée.
- Un /reload suffit.

## 0.19.0 · 27/11/2026

- Cadres d'unité : nouvelle barre d'incantation du joueur, collée sous son cadre et à sa largeur, au style sobre de
  CœurUI. Icône du sort, nom, temps restant et total ; zone de latence au bout de la barre ; repères des tics sur
  les canalisations les plus courantes.
- Bleu pendant une incantation, vert pendant une canalisation (la barre se vide), rouge « Interrompu » ou « Échec »
  quand le sort ne part pas ; elle s'efface ensuite.
- Option « Détacher du cadre » : la barre se place alors seule avec le cadenas, avec sa propre largeur.
- Réglages dans la page « Joueur », section « Barre d'incantation » : afficher, détacher, hauteur, largeur, temps
  affiché, icône, nom, latence, tics.
- La barre d'incantation du jeu est cachée tant que celle de CœurUI est affichée ; elle revient quand on la coupe.
- Le cadre du familier suit maintenant le cadre du joueur : juste dessous, ou sous la barre d'incantation quand elle
  y est attachée (il remonte quand on la détache ou la coupe). Sa place est remise à zéro une fois : le replacer
  avec le cadenas si besoin.
- La fenêtre de CœurUI se cache pendant un combat et revient à la fin, sur la même page. Ouverte en combat (/cui,
  bouton de minicarte) : elle s'ouvre à la fin du combat.
- Correction (Cadres d'unité) : changer un réglage de la barre d'incantation en combat provoquait une erreur
  « action bloquée ».
- Un /reload suffit.

## 0.18.0 · 26/11/2026

- Nouveau module « Suivi des quêtes » (coupé d'office) : le suivi des quêtes du jeu au style sobre de CœurUI. Titres
  de section gris, titre de quête dans la couleur de sa difficulté, objectifs gris clair (faits : en vert), barres
  de progression sobres, fond sombre léger réglable.
- Placé avec le cadenas ; largeur et hauteur maximale réglables ; tailles des titres et des objectifs.
- Repli automatique en combat et en donjon ou raid (il se déplie tout seul après ; jamais un suivi replié à la main).
- Objectifs colorés selon leur avancée : rouge (pas commencé), jaune (à moitié), vert (fait), en dégradé ; « À rendre »
  en vert quand la quête est terminée.
- La ligne « Tous les objectifs » du jeu est retirée ; chaque section garde son bouton de repli. Le fond est centré
  sur les quêtes, icônes comprises.
- Clic droit sur une quête : « Lien Wowhead », une petite fenêtre avec l'adresse de la quête prête à copier (Ctrl+C).
- Couper le module demande un rechargement de l'interface.
- Tooltips : les infobulles de survol (unités dans le monde, cadres, boutons du jeu...) se placent avec le cadenas
  (cadre « Infobulles », en bas à droite par défaut) ; elles grandissent depuis le coin le plus proche du bord.
- Correction (Minicarte) : le contour de la carte était irrégulier (côtés plus épais, coins flous) ; il est maintenant
  d'un pixel d'écran exactement, à toute échelle d'interface.
- Minicarte : le menu du suivi s'ouvre contre la carte, aligné sur son haut (du côté du centre de l'écran).
- Grille du cadenas : nouvelle taille 4 (en plus de 8, 16, 32, 48 et 64), pour placer au plus près.
- Cadenas : la fenêtre de CœurUI se cache quand on déverrouille les cadres, et revient sur la même page au
  verrouillage.
- Redémarrer le jeu.

## 0.17.1 · 26/11/2026

- Correction (Cadres d'unité) : aucune infobulle ne s'affichait au survol des cadres du joueur, de la cible et de la
  cible de la cible ; le survol montre maintenant l'infobulle de l'unité, comme sur les cadres du jeu.
- Correction (Cadres d'unité) : le cadre du familier avait disparu avec celui du joueur. Nouveau cadre « Familier »,
  petit comme celui de la cible de la cible (nom et barre de vie), avec son sous-onglet de réglages et sa place au
  cadenas ; il n'apparaît qu'avec un familier.
- Tooltips : plus de barre de vie sous l'infobulle d'une unité.
- Tooltips : dans l'infobulle d'un joueur, la classe est écrite dans sa couleur et la faction dans la sienne (Alliance
  en bleu, Horde en rouge).
- Cadres d'unité : l'infobulle n'a plus la consigne verte « Clic droit pour les paramètres de bordure ».
- Un /reload suffit.

## 0.17.0 · 26/11/2026

- Tooltips : nouvelle page de réglages avec l'option « Afficher les identifiants » (activée d'office) : en bas des
  infobulles, l'ID des sorts (barres, grimoire, talents), des effets (améliorations, affaiblissements) et des objets
  (sacs, équipement, liens, marchands), en gris discret.
- Un /reload suffit.

## 0.16.0 · 26/11/2026

- Barres d'actions, étape 3 : le micro-menu (personnage, métiers, sorts et talents, hauts faits, quêtes, guilde,
  recherche de groupe, collections, journal, boutique, menu...) en carrés sobres avec des icônes CœurUI au trait ;
  une pastille rouge quand le jeu signale quelque chose, gris sombre quand un bouton est désactivé.
- Les sacs (sac de composants, quatre sacs, sac à dos) en carrés sobres ; places libres gardées.
- Tous deux se placent avec le cadenas ; rangées, sens, taille, espacement, visibilité, opacité (le nombre de
  boutons est celui du jeu).
- « Barres d'actions » devient un tiroir dans la fenêtre : « Barres » (les barres 1 à 8 réunies, un menu choisit la
  barre), puis une page chacun pour Familier, Postures et formes (seulement si le personnage en a), Bouton d'action
  en plus, Quitter le véhicule, Micro-menu et Sacs, avec seulement leurs réglages.
- Familier : toujours ses 10 boutons sur une rangée ; « Nombre de boutons » et « Boutons par rangée » retirés de sa
  page (le sens, la taille et l'espacement restent).
- Micro-menu et sacs : toujours sur une rangée (ou une colonne en sens vertical) ; « Boutons par rangée » retiré de
  leurs pages. L'aperçu est retiré de toutes les pages (la vraie barre change tout de suite).
- Le module « Infobulles et menus » s'appelle maintenant « Tooltips » (rien ne change dans ses réglages).
- Correction : des erreurs Lua ("SetCooldown ... Secret values") apparaissaient en combat sur les barres 1 à 8. Les
  barres utilisent maintenant les boutons d'action du jeu (rangés et habillés par CœurUI) : le jeu met lui-même à jour
  recharges, sorts et raccourcis.
- Correction : une erreur Lua (Blizzard_MicroMenu, GetEdgeButton) apparaissait quand le micro-menu était rangé ; ses
  boutons restent maintenant dans le micro-menu du jeu, seulement placés sur la barre CœurUI.
- Correction : les boutons du micro-menu étaient mal alignés et de tailles différentes (échelle du micro-menu du jeu,
  réarrangements du jeu) ; ils sont remis en place tout seuls.
- Micro-menu adapté à WoW Forever : plus de Logis, de Guide de l'aventurier ni de hauts faits (ils n'y existent pas),
  ni du bouton « sorts et talents » récent qui y faisait doublon (étoile en trop, mauvais raccourcis) ; le bouton
  Héritage de Forever (couronne) a sa place après les talents (il restait seul à l'ancienne place du micro-menu) ;
  le grimoire (livre) a son bouton, les talents (étoile) le leur ; l'assistance a son icône (point d'interrogation).
- Correction : sur les sacs (et parfois ailleurs), les images touchaient les bords et le liseré gris ne se voyait pas ;
  le liseré est maintenant toujours visible, par-dessus l'image.
- Correction : les icônes restaient teintées de rouge quelle que soit la distance de la cible ; le rouge est
  maintenant un voile posé seulement quand le jeu indique « hors de portée », la couleur de l'icône reste celle du jeu.
- Redémarrer le jeu (nouvelles textures).

## 0.15.0 · 26/11/2026

- Barres d'actions, étape 2 : la barre du familier et celle des postures (ou formes) en carrés sobres, au-dessus des
  barres ; mêmes réglages que les barres (jusqu'à 10 boutons). La barre du familier n'apparaît qu'avec un familier.
- Un personnage sans posture ni forme ne voit pas « Postures et formes » (ni dans la page, ni au cadenas) ; elle
  apparaît dès qu'il en apprend une.
- Bouton d'action en plus (combats de boss, quêtes) et capacité de zone : sans leur décor du jeu, à la taille et à la
  place voulues.
- Quitter le véhicule : un carré sobre avec une icône CœurUI au trait, seulement en véhicule.
- Chacun se place avec le cadenas ; ils se choisissent dans le menu « Barre » de la page (pour les deux boutons
  spéciaux, seule la taille se règle).
- Redémarrer le jeu (nouvelle texture).

## 0.14.0 · 26/11/2026

- Nouveau module « Barres d'actions » (coupé d'office), première étape : les barres 1 à 8 en carrés sobres (icône
  rognée, liseré gris fin, pas d'or), à la place des barres du jeu. Raccourcis du jeu gardés.
- Pour chaque barre, sur une seule page (un menu choisit la barre) : l'afficher ou non, nombre de boutons (1 à
  12), boutons par rangée, sens horizontal ou vertical, taille, espacement ; quand l'afficher (toujours, au survol
  seulement, en combat seulement, jamais) et opacité hors survol ; raccourci, nom des macros, charges.
- Hors de portée : icône teintée en rouge. Sort mis en avant par le jeu : halo blanc au lieu de doré.
- Les barres se placent avec le cadenas (grille aimantée). Un réglage changé en combat s'applique à la sortie.
- Familier, postures, boutons spéciaux, micro-menu et sacs : prochaines étapes du module.
- Couper le module demande un rechargement de l'interface.
- Redémarrer le jeu.

## 0.13.0 · 26/11/2026

- Cadenas ouvert : une grille fine s'affiche sous l'interface, partie du centre de l'écran (axes du centre en
  doré). Dans le panneau « Déplacement des cadres » : l'afficher ou non, et sa taille (8, 16, 32, 48 ou 64).
- Aimant (activé d'office, se coupe dans le même panneau) : un cadre glissé se colle à la grille, aux bords des
  autres cadres (alignés ou collés) et au centre de l'écran ; un trait vert montre ce qui l'attire. Maj enfoncée :
  déplacement libre.
- Un /reload suffit.

## 0.12.0 · 26/11/2026

- Nouveau module « Infobulles et menus » (coupé d'office) : les infobulles du jeu (unités, objets, sorts...) et ses
  menus déroulants (ex. menu du suivi de la minicarte) prennent le style sobre de CœurUI : fond sombre, liseré gris
  fin, pas d'or. La barre de vie sous une infobulle devient un trait fin ; les textes prennent la police de CœurUI.
- Les infobulles et les menus de CœurUI passent aussi au style sobre (plus de contour ni de titre dorés).
- Correction (Minicarte) : certains addons apparaissaient encore deux fois dans le tiroir (leur bouton, plus une
  copie tirée du menu des addons du jeu).
- Correction (Minicarte) : posé sur la carte avec le cadenas, le bouton du tiroir ne répondait pas au clic.
- Minicarte : le tiroir s'ouvre sur le côté de la carte (vers le centre de l'écran) et a le cadre sobre de CœurUI
  (fond sombre, liseré gris fin) au lieu d'un rectangle noir.
- Minicarte : dans le tiroir, chaque bouton d'addon a le même habit, un rond sobre CœurUI (image en rond, fond
  graphite, liseré gris fin qui s'éclaircit au survol) ; les addons ajoutés plus tard le prennent aussi.
- Couper le module demande un rechargement de l'interface.
- Redémarrer le jeu.

## 0.11.0 · 26/11/2026

- Nouvelle entrée « Général » dans la fenêtre, juste sous « Tous les modules » : les réglages communs à tout
  CœurUI.
- Pour commencer, la police : elle change d'un coup les fenêtres de CœurUI et les textes de tous les modules
  (cadres d'unité, minicarte...).
- La police n'est plus réglée dans Cadres d'unité > Général (les tailles y restent) ; celle que vous aviez choisie
  y est reprise.
- Minicarte : plus d'infobulle au survol des icônes du courrier, du suivi et du tiroir.
- Nouvelle icône dans la barre de titre de la fenêtre, à gauche du cadenas : recharger l'interface d'un clic
  (grisée en combat).
- Redémarrer le jeu (nouvelle texture).

## 0.10.1 · 26/11/2026

- Minicarte : courrier, suivi, file d'attente et tiroir ont leurs icônes CœurUI (trait fin, gris clair, blanc au
  survol) ; une pastille rouge signale le courrier arrivé.
- Correction : le tiroir montrait deux fois certains addons (leur bouton, plus le menu des addons du jeu « 3 »). Le
  menu du jeu n'y est plus ; seuls les addons qui n'ont pas de bouton y gardent une place.
- Correction : des restes de la minicarte du jeu (textes, décors) restaient visibles à son ancienne place.
- Correction : une erreur Lua (Blizzard_Minimap) apparaissait à chaque arrivée de courrier.
- Cadenas ouvert : on peut aussi déplacer un élément en glissant son étiquette (son nom), plus simple pour les petits
  éléments de la minicarte ; un élément posé sur la carte s'attrape sans entraîner la carte. L'étiquette de la carte
  passe en dessous, pour ne plus cacher celle du nom de la zone.
- Redémarrer le jeu (nouvelles textures).

## 0.10.0 · 26/11/2026

- Nouveau module « Minicarte » (coupé d'office) : minicarte sobre, carrée ou rectangulaire (largeur et hauteur
  réglables), avec le nom de la zone, les coordonnées en bas de la carte et le zoom à la molette.
- Boutons du jeu gardés : courrier, suivi, file d'attente. Plus d'heure ni de calendrier sur la carte.
- Les boutons des addons sont rangés dans un tiroir qui s'ouvre d'un clic.
- Avec le cadenas, on place la carte, le nom de la zone, le tiroir et chaque bouton du jeu ; les éléments suivent la
  carte quand on la déplace.
- Couper le module demande un rechargement de l'interface.
- Redémarrer le jeu.

## 0.9.0 · 26/11/2026

- Nouveau module « Cadres d'unité » (coupé d'office) : cadres du joueur, de la cible et de la cible de la cible, à
  la place de ceux du jeu. Couper le module demande un rechargement de l'interface.
- Page « Général » : police, taille de chaque libellé (nom, niveau, vie) et texture des barres, pour tous les cadres.
- Pages Joueur, Cible, Cible de la cible : taille, texte et couleur de la vie, éléments, avec un aperçu.
- Le cadenas de la fenêtre déverrouille les cadres pour les placer à la souris.
- Redémarrer le jeu.

## 0.8.0 · 26/11/2026

- Le module « Essai », qui servait aux tests, est retiré. S'il était actif, la plaque des PNJ amis revient à son
  réglage d'origine.
- Un cadenas dans la barre de titre servira à déverrouiller les cadres pour les déplacer (avec les prochains
  modules qui ont des cadres).
- La version de CœurUI s'affiche dans la barre de titre de la fenêtre.
- Correction : « Paramètres » avait un trait doré à gauche alors qu'il n'était pas choisi.
- Redémarrer le jeu.

## 0.7.0 · 26/11/2026

- Nouvelle page « Paramètres », en bas à gauche de la fenêtre : réglages généraux de CœurUI.
- CœurUI parle anglais : choix de la langue dans « Paramètres » (par défaut celle du jeu), après un
  rechargement de l'interface. Les commandes marchent en français et en anglais (`/cui help`, `enable`, `disable`).
- Le bouton de minicarte n'est plus un module : on l'affiche ou le cache dans « Paramètres ». Sa place est gardée.
- Correction : « Paramètres » avait une pastille blanche, comme un module, alors que ce n'en est pas un.
- Redémarrer le jeu.

## 0.6.0 · 26/11/2026

- Nouvelle fenêtre principale (`/cui` ou le bouton de minicarte) : les modules sont rangés à gauche, en tiroirs
  qui s'ouvrent sur leurs sous-modules.
- Accueil « Tous les modules » : une carte par module, avec son interrupteur et un lien vers ses réglages.
- Les réglages d'un module ou d'un sous-module s'ouvrent à droite ; la molette fait défiler les longues pages.

## 0.5.0 · 26/11/2026

- Nouveau module « Bouton de minicarte », actif d'office : un clic ouvre la fenêtre des modules, on le glisse
  autour de la minicarte pour le déplacer.
- Correction : rangé par un addon de minicarte (EllesmereUIMinimap), le contour doré du bouton était coupé.
- Redémarrer le jeu.

## 0.4.0 · 26/11/2026

- Fenêtre « Modules » : bouton « Réglages » sur la ligne d'un module qui a des réglages ; son panneau s'ouvre dans
  la même fenêtre, retour par « « Modules ».
- Les réglages s'appliquent tout de suite ; « Valeurs par défaut » remet tout à zéro.
- Nouveaux curseur et menu déroulant.
- Correction : le bouton rond du curseur était caché sous son liseré (on ne voyait qu'un trou).
- Redémarrer le jeu.

## 0.3.0 · 26/11/2026

- Fenêtre « Modules » : bouton « Recharger l'interface » quand un module attend un /reload pour être coupé.
- En combat, ce bouton est grisé et revient à la sortie du combat.
- Redémarrer le jeu.

## 0.2.0 · 26/11/2026

- Nouvelle fenêtre « Modules » : `/cui` l'ouvre, un interrupteur par module pour l'activer ou le couper.
- La fenêtre se déplace par sa barre de titre et garde sa place ; Échap la ferme.
- L'aide des commandes passe par `/cui aide`.
- Redémarrer le jeu.

## 0.1.1 · 26/11/2026

- CœurUI a maintenant son icône dans la liste des addons.
- Couleurs du thème accordées à celles de l'icône (or, rouge du cœur).
- Redémarrer le jeu.

## 0.1.0 · 26/11/2026

- Première version : CœurUI se charge et garde ses réglages d'une session à l'autre.
- Commande `/cui` : version, liste des modules, activer ou couper un module, remise à zéro.
- Un module coupé rend au jeu les réglages qu'il avait changés, même après une déconnexion.
- Un module activé ou coupé en combat l'est à la sortie du combat.
- Module « Essai » pour tester le noyau (sera retiré avant la publication).
- Redémarrer le jeu.
