# CœurUI : feuille de route

## En cours

- Noyau, en 4 étapes testées une par une :
  1. ~~Socle : chargement, évènements, minuteries, réglages, registre des modules, commande `/cui` (sans fenêtre).~~
     Validé en jeu (0.1.0).
  2. ~~Thème, fenêtre, bouton, interrupteur, infobulle, écran « Modules ».~~ Validé en jeu (0.2.0).
  3. ~~Bouton /reload protégé, report des changements en combat.~~ Validé en jeu (0.3.0).
  4. ~~Curseur et menu déroulant dans un panneau de réglages.~~ Validé en jeu (0.4.0).
  5. ~~Fenêtre principale (maquette A + accueil C validés) : modules à gauche en tiroirs avec leurs sous-modules,
     accueil « Tous les modules » en cartes, réglages à droite.~~ Validé en jeu (0.6.0).
  6. Page « Paramètres » et traduction anglaise possible :
     - une entrée « Paramètres » fixe dans la colonne de gauche (réglages généraux de CœurUI, pas un module qu'on
       coupe) ;
     - choix de la langue (français / anglais, par défaut celle du jeu), appliqué après un /reload ;
     - réglage du bouton de minicarte (afficher ou non) rangé là ;
     - tous les textes, ceux des modules compris, passent par les fichiers de `Locales/` (`frFR.lua`, `enUS.lua`).
     Maquette à valider avant le code.

## Ensuite (dans l'ordre, un à la fois)

1. ~~Icône et logo : script `tools/` qui génère les TGA à partir de la planche du joueur, `IconTexture` dans le `.toc`,
   couleurs du thème affinées sur la planche.~~ Validé en jeu (0.1.1).
2. ~~Premier module d'interface : bouton de minicarte.~~ Validé en jeu (0.5.0).
3. Modules d'interface, un à la fois (chacun : maquette validée, puis code, puis tests en jeu) :
   1. Barres de vie.
   2. Minicarte (le joueur désactivera EllesmereUIMinimap quand ce module sera prêt).
   3. Barres d'actions.
   4. Barre d'incantation (cast).
   5. Discussion (tchat).
   6. Effets : améliorations et affaiblissements (buffs et débuffs).
   7. Suivi des quêtes.
4. Client PC minimal : mises à jour de l'addon.

## Avant la première publication

- Retirer le module « Essai » (sert seulement à tester le noyau).

## Plus tard

Idées notées pendant le travail, pas encore commencées.

