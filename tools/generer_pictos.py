"""Génère les icônes de l'interface de CœurUI (direction « trait + pastille », voir CLAUDE.md).

Dessin au trait de 1,75 sur une grille de 24, bouts arrondis, blanc sur fond transparent : le jeu
les teinte (gris clair au repos, blanc au survol, gris sombre désactivé). La pastille d'alerte est
le disque Media/Cercle.tga teinté en rouge cœur.

Usage : python tools/generer_pictos.py   (demande Pillow : pip install pillow)
Sortie : CoeurUI/Media/Icones/<Nom>.tga, 64 px, TGA 32 bits.
"""

import math
from pathlib import Path

from PIL import Image, ImageDraw

TAILLE = 64
SUR = 8                      # suréchantillonnage pour des bords lisses
GRILLE = 24
TRAIT = 1.75
BLANC = (255, 255, 255, 255)

RACINE = Path(__file__).resolve().parent.parent
SORTIE = RACINE / "CoeurUI" / "Media" / "Icones"

K = TAILLE * SUR / GRILLE    # unités de la grille de 24 vers pixels de travail
LARGEUR = TRAIT * K


def p(x, y):
    return (x * K, y * K)


def tampon(d, points):
    """Trait épais à bouts ronds : des disques posés le long des points."""
    r = LARGEUR / 2
    for i in range(len(points) - 1):
        (x0, y0), (x1, y1) = points[i], points[i + 1]
        n = max(1, int(math.hypot(x1 - x0, y1 - y0) / (r / 4)))
        for j in range(n + 1):
            t = j / n
            x, y = x0 + (x1 - x0) * t, y0 + (y1 - y0) * t
            d.ellipse([x - r, y - r, x + r, y + r], fill=BLANC)


def ligne(d, *pts):
    tampon(d, [p(x, y) for x, y in pts])


def bezier(a, b, c, e, n=40):
    out = []
    for i in range(n + 1):
        t = i / n
        u = 1 - t
        out.append((u ** 3 * a[0] + 3 * u * u * t * b[0] + 3 * u * t * t * c[0] + t ** 3 * e[0],
                    u ** 3 * a[1] + 3 * u * u * t * b[1] + 3 * u * t * t * c[1] + t ** 3 * e[1]))
    return out


def cercle(d, cx, cy, r, n=96):
    tampon(d, [p(cx + r * math.cos(2 * math.pi * i / n), cy + r * math.sin(2 * math.pi * i / n)) for i in range(n + 1)])


def rect_arrondi(d, x, y, w, h, r, n=12):
    pts = []
    coins = [(x + w - r, y + r, -90), (x + w - r, y + h - r, 0), (x + r, y + h - r, 90), (x + r, y + r, 180)]
    for cx, cy, debut in coins:
        for i in range(n + 1):
            a = math.radians(debut + 90 * i / n)
            pts.append((cx + r * math.cos(a), cy + r * math.sin(a)))
    pts.append(pts[0])
    tampon(d, [p(*q) for q in pts])


def courrier(d):
    rect_arrondi(d, 3.5, 5.5, 17, 13, 2)
    ligne(d, (4, 7), (12, 13), (20, 7))


def suivi(d):
    cercle(d, 10.5, 10.5, 6)
    ligne(d, (15, 15), (20, 20))


def file_attente(d):
    haut = bezier((2.5, 12), (6, 5.5), (18, 5.5), (21.5, 12))
    bas = bezier((21.5, 12), (18, 18.5), (6, 18.5), (2.5, 12))
    tampon(d, [p(*q) for q in haut + bas])
    cercle(d, 12, 12, 2.5)


def tiroir(d):
    for x, y in ((4, 4), (13.5, 4), (4, 13.5), (13.5, 13.5)):
        rect_arrondi(d, x, y, 6.5, 6.5, 1.2)


def categories(d):
    """Liste rangée : trois rubriques, une petite case et un trait chacune."""
    for y in (4, 10.25, 16.5):
        rect_arrondi(d, 3.5, y, 3.5, 3.5, 0.8)
        ligne(d, (10, y + 1.75), (20.5, y + 1.75))


def cadenas(d):
    """Cadenas : corps arrondi, anse en arc au-dessus."""
    rect_arrondi(d, 5, 11, 14, 9.5, 2)
    arc = [(12 + 4.5 * math.cos(math.radians(a)), 11 - 0.5 + 4.5 * math.sin(math.radians(a)) - 0)
           for a in [180 + 180 * i / 40 for i in range(41)]]
    ligne(d, (7.5, 11), (7.5, 10.5))
    ligne(d, (16.5, 11), (16.5, 10.5))
    tampon(d, [p(*q) for q in arc])


def role_tank(d):
    """Bouclier (rôle tank)."""
    gauche = bezier((12, 20.5), (7.5, 18.5), (5, 15.5), (5, 11))
    droite = bezier((19, 11), (19, 15.5), (16.5, 18.5), (12, 20.5))
    tampon(d, [p(*q) for q in [(12, 3.5), (19, 6), (19, 11)] + droite + gauche + [(5, 6), (12, 3.5)]])


def role_soin(d):
    """Croix (rôle soigneur)."""
    ligne(d, (12, 4.5), (12, 19.5))
    ligne(d, (4.5, 12), (19.5, 12))


def role_degats(d):
    """Épée (rôle dégâts) : lame (contour) en diagonale, garde, poignée."""
    ligne(d, (16, 4.5), (19.5, 4.5), (19.5, 8), (10, 17.5), (6.5, 14), (16, 4.5))
    ligne(d, (4.5, 12.5), (11.5, 19.5))
    ligne(d, (7, 17), (4.5, 19.5))


def trier(d):
    """Trier : trois traits de plus en plus courts, flèche vers le bas à droite."""
    ligne(d, (4, 6.5), (13, 6.5))
    ligne(d, (4, 12), (10.5, 12))
    ligne(d, (4, 17.5), (8, 17.5))
    ligne(d, (17.5, 5), (17.5, 19))
    ligne(d, (14, 15.5), (17.5, 19), (21, 15.5))


def chevron(d):
    """Chevron vers le bas (déplié) ; tourné d'un quart de tour dans le jeu pour « replié »."""
    ligne(d, (6, 9), (12, 15), (18, 9))


def tag_elite(d):
    """Couronne (quête élite)."""
    ligne(d, (4.5, 18), (19.5, 18))
    ligne(d, (4.5, 18), (4, 8), (8.5, 12), (12, 5.5), (15.5, 12), (20, 8), (19.5, 18))


def tag_donjon(d):
    """Porte en arc (quête de donjon)."""
    arc = bezier((5, 11), (5, 3.5), (19, 3.5), (19, 11))
    tampon(d, [p(*q) for q in [(5, 20)] + arc + [(19, 20)]])
    ligne(d, (3.5, 20), (20.5, 20))
    ligne(d, (12, 7.5), (12, 20))


def tag_raid(d):
    """Crâne (quête de raid)."""
    gauche = bezier((8.5, 17), (4.5, 15.5), (4, 11), (5, 9))
    haut = bezier((5, 9), (6.5, 3.5), (17.5, 3.5), (19, 9))
    droite = bezier((19, 9), (20, 11), (19.5, 15.5), (15.5, 17))
    tampon(d, [p(*q) for q in gauche + haut + droite + [(15.5, 20.5), (8.5, 20.5), (8.5, 17)]])
    cercle(d, 9.2, 11.5, 1.6)
    cercle(d, 14.8, 11.5, 1.6)


def tag_groupe(d):
    """Deux silhouettes (quête de groupe)."""
    cercle(d, 9, 8, 3)
    tampon(d, [p(*q) for q in bezier((3.5, 19.5), (3.5, 13), (14.5, 13), (14.5, 19.5))])
    cercle(d, 16.5, 7, 2.5)
    tampon(d, [p(*q) for q in bezier((16, 12.5), (19.5, 12.5), (21, 14.5), (21, 18))])


def recharger(d):
    """Flèche en cercle (recharger l'interface) : arc de 300°, pointe en haut à droite."""
    cx, cy, r = 12, 12, 7
    debut, fin = 40, 340  # degrés, sens horaire à l'écran (y vers le bas)
    arc = [(cx + r * math.cos(math.radians(a)), cy + r * math.sin(math.radians(a)))
           for a in [debut + (fin - debut) * i / 80 for i in range(81)]]
    tampon(d, [p(*q) for q in arc])
    a = math.radians(fin)
    tx, ty = arc[-1]
    dx, dy = -math.sin(a), math.cos(a)      # sens de la flèche (tangente)
    nx, ny = -dy, dx                        # perpendiculaire
    ligne(d, (tx - 3.5 * dx + 3 * nx, ty - 3.5 * dy + 3 * ny), (tx + 0.6 * dx, ty + 0.6 * dy))
    ligne(d, (tx - 3.5 * dx - 3 * nx, ty - 3.5 * dy - 3 * ny), (tx + 0.6 * dx, ty + 0.6 * dy))


def sortie(d):
    """Quitter (le véhicule) : porte ouverte à gauche, flèche qui sort vers la droite."""
    ligne(d, (11, 4), (5, 4), (5, 20), (11, 20))
    ligne(d, (10, 12), (20, 12))
    ligne(d, (16, 8), (20, 12), (16, 16))


def chemin(d, *pts):
    """Ligne brisée qui revient à son point de départ."""
    ligne(d, *pts, pts[0])


# Micro-menu (barres d'actions) ------------------------------------------------------------------

def personnage(d):
    cercle(d, 12, 8.5, 3.5)
    tampon(d, [p(*q) for q in bezier((4.5, 20), (4.5, 14), (19.5, 14), (19.5, 20))])


def metiers(d):
    """Marteau."""
    ligne(d, (5, 19.5), (13, 11.5))
    chemin(d, (11, 7.5), (15, 3.5), (20.5, 9), (16.5, 13))


def sorts(d):
    """Grimoire fermé."""
    rect_arrondi(d, 5.5, 3.5, 13, 17, 2)
    ligne(d, (9.5, 3.5), (9.5, 20.5))


def succes(d):
    """Bouclier."""
    tampon(d, [p(*q) for q in [(12, 3), (19, 6), (19, 11)]
               + bezier((19, 11), (19, 16), (15.5, 19.5), (12, 21))
               + bezier((12, 21), (8.5, 19.5), (5, 16), (5, 11))
               + [(5, 6), (12, 3)]])


def quetes(d):
    """Point d'exclamation."""
    ligne(d, (12, 4), (12, 14.5))
    ligne(d, (12, 19.5), (12, 19.6))


def guilde(d):
    """Étendard."""
    ligne(d, (6, 21), (6, 3.5))
    ligne(d, (6, 4), (18, 4), (15, 8.5), (18, 13), (6, 13))


def groupes(d):
    """Deux personnes."""
    cercle(d, 9, 9, 3)
    tampon(d, [p(*q) for q in bezier((3, 20), (3, 15), (15, 15), (15, 20))])
    cercle(d, 16.5, 8, 2.5)
    tampon(d, [p(*q) for q in bezier((16, 13.5), (19.5, 13.5), (21, 16), (21, 19))])


def collections(d):
    """Coffre."""
    rect_arrondi(d, 4, 9.5, 16, 10.5, 1.5)
    ligne(d, (4, 9.5), (6, 5), (18, 5), (20, 9.5))
    ligne(d, (12, 12.5), (12, 15.5))


def journal(d):
    """Livre ouvert."""
    chemin(d, (3, 6), (12, 8), (21, 6), (21, 19), (12, 21), (3, 19))
    ligne(d, (12, 8), (12, 21))


def boutique(d):
    """Sac de boutique."""
    rect_arrondi(d, 5, 8, 14, 12.5, 2)
    tampon(d, [p(*q) for q in bezier((9, 8), (9, 3.5), (15, 3.5), (15, 8))])


def menu(d):
    for y in (7, 12, 17):
        ligne(d, (5, y), (19, y))


def logement(d):
    """Maison."""
    ligne(d, (3.5, 11.5), (12, 4), (20.5, 11.5))
    ligne(d, (6, 9.5), (6, 20), (18, 20), (18, 9.5))
    ligne(d, (10, 20), (10, 15), (14, 15), (14, 20))


def talents(d):
    """Étoile."""
    pts = []
    for i in range(10):
        a = math.radians(-90 + 36 * i)
        r = 8.5 if i % 2 == 0 else 3.8
        pts.append((12 + r * math.cos(a), 12.8 + r * math.sin(a)))
    chemin(d, *pts)


def heritage(d):
    """Couronne (Héritage, à la place des hauts faits sur Forever)."""
    chemin(d, (4, 18), (4, 8), (8.5, 12), (12, 5), (15.5, 12), (20, 8), (20, 18))


def aide(d):
    """Point d'interrogation (assistance)."""
    tampon(d, [p(*q) for q in bezier((8.5, 9), (8.5, 4.5), (15.5, 4.5), (15.5, 9))
               + bezier((15.5, 9), (15.5, 11.5), (12, 12), (12, 14.5))])
    ligne(d, (12, 19.5), (12, 19.6))


def copier(d):
    """Deux feuilles (copier la discussion)."""
    rect_arrondi(d, 8.5, 8.5, 11.5, 11.5, 2)
    ligne(d, (15.5, 8.5), (15.5, 6), (15, 4.5), (6, 4.5), (4.5, 6), (4.5, 15), (6, 15.5), (8.5, 15.5))


def bas(d):
    """Flèche vers le bas sur un trait (descendre en bas de la discussion)."""
    ligne(d, (12, 4.5), (12, 16))
    ligne(d, (6.5, 10.5), (12, 16), (17.5, 10.5))
    ligne(d, (6, 19.5), (18, 19.5))


# Fiche du personnage (petits onglets en haut des statistiques) -----------------------------------

def statistiques(d):
    """Toile des caractéristiques : pentagone, et dedans le relevé (un pentagone inégal)."""
    def sommet(i, r):
        a = math.radians(-90 + 72 * i)
        return (12 + r * math.cos(a), 12.5 + r * math.sin(a))
    chemin(d, *[sommet(i, 8) for i in range(5)])
    chemin(d, *[sommet(i, 4 if i % 2 else 5.2) for i in range(5)])


def titre(d):
    """Trois traits horizontaux (la liste des titres)."""
    for y in (7, 12, 17):
        ligne(d, (5, y), (19, y))


def ensembles(d):
    """Cuirasse (ensembles d'équipement)."""
    chemin(d, (9, 4), (5, 5.5), (3.5, 11), (6.5, 12), (7, 20), (17, 20), (17.5, 12), (20.5, 11), (19, 5.5),
           (15, 4), (12, 7))


# Fiche du personnage : onglets de côté et boutons du personnage ----------------------------------

def reputation(d):
    """Médaille : disque et ruban (réputation)."""
    cercle(d, 12, 9, 5)
    ligne(d, (8.6, 12.7), (7, 21), (12, 18.5), (17, 21), (15.4, 12.7))


def jcj(d):
    """Deux épées croisées, avec leur garde (JcJ)."""
    ligne(d, (4, 4), (20, 20))
    ligne(d, (20, 4), (4, 20))
    ligne(d, (15, 19), (19, 15))
    ligne(d, (5, 15), (9, 19))


def monnaies(d):
    """Pile de pièces (monnaies)."""
    n = 64
    haut = [(12 + 7 * math.cos(2 * math.pi * i / n), 6.5 + 2.8 * math.sin(2 * math.pi * i / n)) for i in range(n + 1)]
    tampon(d, [p(*q) for q in haut])
    for y in (6.5, 11.5):
        bas = [(12 + 7 * math.cos(math.pi * i / n), y + 5 + 2.8 * math.sin(math.pi * i / n)) for i in range(n + 1)]
        tampon(d, [p(19, y)] + [p(*q) for q in bas] + [p(5, y)])


def courbe(d):
    """Axes et courbe qui monte (statistiques du jeu)."""
    ligne(d, (4, 4), (4, 20), (20, 20))
    ligne(d, (7.5, 15), (11, 10.5), (14, 13.5), (19, 7.5))


def loupe(d):
    cercle(d, 10.5, 10.5, 6)
    ligne(d, (15, 15), (20, 20))


def zoom_plus(d):
    loupe(d)
    ligne(d, (10.5, 8), (10.5, 13))
    ligne(d, (8, 10.5), (13, 10.5))


def zoom_moins(d):
    loupe(d)
    ligne(d, (8, 10.5), (13, 10.5))


def demi_tour(d, sens):
    """Flèche en U : part d'en haut, revient en bas (sens 1 : vers la gauche, -1 : vers la droite)."""
    def x(v):
        return v if sens == 1 else 24 - v
    arc = [(x(15 + 5 * math.sin(math.pi * i / 24)), 14 - 5 * math.cos(math.pi * i / 24)) for i in range(25)]
    tampon(d, [p(x(5), 9)] + [p(*q) for q in arc] + [p(x(10), 19)])
    ligne(d, (x(8.5), 5.5), (x(5), 9), (x(8.5), 12.5))


def tourner_gauche(d):
    demi_tour(d, 1)


def tourner_droite(d):
    demi_tour(d, -1)


def ranger_sac(d):
    """Sac et flèche qui descend dedans (ranger la pièce dans les sacs)."""
    rect_arrondi(d, 4.5, 11, 15, 10, 2)
    ligne(d, (12, 2.5), (12, 13.5))
    ligne(d, (8.5, 10), (12, 13.5), (15.5, 10))


def ignorer(d):
    """Cercle barré (ignorer l'emplacement)."""
    cercle(d, 12, 12, 7.5)
    ligne(d, (6.7, 17.3), (17.3, 6.7))


# Résistances (fiche du personnage) : une forme par école de magie -----------------------------------

def res_arcanes(d):
    """Étoile scintillante à quatre branches."""
    chemin(d, (12, 3), (13.8, 10.2), (21, 12), (13.8, 13.8), (12, 21), (10.2, 13.8), (3, 12), (10.2, 10.2))


def res_feu(d):
    """Flamme, et une petite flamme dedans."""
    tampon(d, [p(*q) for q in bezier((12, 21), (6.5, 21), (5, 16), (7.5, 12.5))
               + bezier((7.5, 12.5), (9.5, 9.5), (10, 6), (12, 3))
               + bezier((12, 3), (15, 7), (19, 11), (18.5, 15.5))
               + bezier((18.5, 15.5), (18, 19), (15.5, 21), (12, 21))])
    tampon(d, [p(*q) for q in bezier((12, 18.2), (10, 18.2), (9.6, 15.6), (12, 13.2))
               + bezier((12, 13.2), (14.4, 15.6), (14, 18.2), (12, 18.2))])


def res_givre(d):
    """Flocon : trois traits croisés, un petit V au bout de chaque branche."""
    for k in range(3):
        a = math.radians(90 + 60 * k)
        ligne(d, (12 + 8.5 * math.cos(a), 12 + 8.5 * math.sin(a)), (12 - 8.5 * math.cos(a), 12 - 8.5 * math.sin(a)))
    for k in range(6):
        a = math.radians(90 + 60 * k)
        bx, by = 12 + 5.5 * math.cos(a), 12 + 5.5 * math.sin(a)
        for side in (-1, 1):
            b = a + side * math.radians(40)
            ligne(d, (bx, by), (bx + 2.6 * math.cos(b), by + 2.6 * math.sin(b)))


def res_nature(d):
    """Feuille et sa nervure."""
    tampon(d, [p(*q) for q in bezier((5, 19), (5, 9), (11, 4), (20, 4)) + bezier((20, 4), (20, 13), (15, 19), (5, 19))])
    ligne(d, (5, 19), (14, 10))


def res_ombre(d):
    """Croissant de lune."""
    cx, cy, r = 12, 12, 8.5
    ix, iy, ir = 16.5, 8.5, 7
    # Points d'intersection des deux cercles (calcul direct), puis l'arc extérieur et l'arc intérieur.
    dx, dy = ix - cx, iy - cy
    dist = math.hypot(dx, dy)
    a = (r * r - ir * ir + dist * dist) / (2 * dist)
    h = math.sqrt(max(0.0, r * r - a * a))
    mx, my = cx + a * dx / dist, cy + a * dy / dist
    p1 = (mx + h * dy / dist, my - h * dx / dist)
    p2 = (mx - h * dy / dist, my + h * dx / dist)
    def angle(c, q):
        return math.atan2(q[1] - c[1], q[0] - c[0])
    def arc(c, rad, a0, a1, n=60):
        return [(c[0] + rad * math.cos(a0 + (a1 - a0) * i / n), c[1] + rad * math.sin(a0 + (a1 - a0) * i / n)) for i in range(n + 1)]
    o0, o1 = angle((cx, cy), p1), angle((cx, cy), p2)
    if o1 < o0:
        o1 += 2 * math.pi
    outer = arc((cx, cy), r, o0, o1)
    # L'arc extérieur doit passer par le côté opposé au cercle intérieur.
    mid = outer[len(outer) // 2]
    if math.hypot(mid[0] - ix, mid[1] - iy) < ir:
        outer = arc((cx, cy), r, o1, o0 + 2 * math.pi)
    i0, i1 = angle((ix, iy), outer[-1]), angle((ix, iy), outer[0])
    inner = arc((ix, iy), ir, i0, i1 if i1 > i0 else i1 + 2 * math.pi)
    mid = inner[len(inner) // 2]
    if math.hypot(mid[0] - cx, mid[1] - cy) > r:
        inner = arc((ix, iy), ir, i0, i1 - 2 * math.pi if i1 > i0 else i1)
    tampon(d, [p(*q) for q in outer + inner])


# Fenêtres du jeu : agrandir et réduire ------------------------------------------------------------

def agrandir(d):
    """Deux flèches vers les coins (agrandir la fenêtre)."""
    ligne(d, (14, 4), (20, 4), (20, 10))
    ligne(d, (20, 4), (13, 11))
    ligne(d, (10, 20), (4, 20), (4, 14))
    ligne(d, (4, 20), (11, 13))


def reduire(d):
    """Deux flèches vers le centre (réduire la fenêtre)."""
    ligne(d, (13, 5), (13, 11), (19, 11))
    ligne(d, (13, 11), (20, 4))
    ligne(d, (11, 19), (11, 13), (5, 13))
    ligne(d, (11, 13), (4, 20))


def familier(d):
    """Empreinte de patte (le familier du chasseur)."""
    tampon(d, [p(*q) for q in bezier((12, 20.5), (7, 20.5), (6.5, 16), (9, 13.5))
               + bezier((9, 13.5), (11, 11.5), (13, 11.5), (15, 13.5))
               + bezier((15, 13.5), (17.5, 16), (17, 20.5), (12, 20.5))])
    for cx, cy in ((5.5, 10.5), (9.5, 6), (14.5, 6), (18.5, 10.5)):
        cercle(d, cx, cy, 1.9)


# Humeur du familier (maquette « 1 quater », façon C) : un cœur plein, à moitié, vide et fêlé ---------

def contour_coeur():
    return (bezier((12, 20), (6, 15.5), (3.5, 12.5), (3.5, 9))
            + bezier((3.5, 9), (3.5, 6.5), (5.5, 4.5), (8, 4.5))
            + bezier((8, 4.5), (9.7, 4.5), (11.1, 5.4), (12, 6.8))
            + bezier((12, 6.8), (12.9, 5.4), (14.3, 4.5), (16, 4.5))
            + bezier((16, 4.5), (18.5, 4.5), (20.5, 6.5), (20.5, 9))
            + bezier((20.5, 9), (20.5, 12.5), (18, 15.5), (12, 20)))


def coeur_rempli(d, depuis_y=None):
    """Intérieur du cœur, en entier ou à partir d'une hauteur (moitié basse)."""
    from PIL import Image, ImageDraw as Dessin
    taille = int(TAILLE * SUR)
    calque = Image.new("L", (taille, taille), 0)
    Dessin.Draw(calque).polygon([p(*q) for q in contour_coeur()], fill=255)
    if depuis_y is not None:
        Dessin.Draw(calque).rectangle([0, 0, taille, p(0, depuis_y)[1]], fill=0)
    d.bitmap((0, 0), calque, fill=BLANC)


def humeur_heureux(d):
    coeur_rempli(d)
    tampon(d, [p(*q) for q in contour_coeur()])


def humeur_content(d):
    coeur_rempli(d, 12)
    tampon(d, [p(*q) for q in contour_coeur()])


def humeur_mecontent(d):
    tampon(d, [p(*q) for q in contour_coeur()])
    ligne(d, (12, 6.8), (10.5, 10), (13, 12.5), (11, 16))


ICONES = {"Copier": copier, "Bas": bas, "Talents": talents, "Heritage": heritage, "Aide": aide, "Courrier": courrier, "Suivi": suivi, "File": file_attente, "Tiroir": tiroir, "Categories": categories, "Trier": trier, "Chevron": chevron, "TagElite": tag_elite, "TagDonjon": tag_donjon, "TagRaid": tag_raid, "TagGroupe": tag_groupe, "Cadenas": cadenas, "RoleTank": role_tank, "RoleSoin": role_soin, "RoleDegats": role_degats, "Recharger": recharger,
          "Sortie": sortie, "Personnage": personnage, "Metiers": metiers, "Sorts": sorts, "Succes": succes,
          "Quetes": quetes, "Guilde": guilde, "Groupes": groupes, "Collections": collections, "Journal": journal,
          "Boutique": boutique, "Menu": menu, "Logement": logement,
          "Statistiques": statistiques, "Titre": titre, "Ensembles": ensembles,
          "Reputation": reputation, "JcJ": jcj, "Monnaies": monnaies, "Courbe": courbe,
          "ZoomPlus": zoom_plus, "ZoomMoins": zoom_moins, "TournerGauche": tourner_gauche,
          "TournerDroite": tourner_droite, "RangerSac": ranger_sac, "Ignorer": ignorer,
          "ResArcanes": res_arcanes, "ResFeu": res_feu, "ResGivre": res_givre, "ResNature": res_nature,
          "ResOmbre": res_ombre, "Agrandir": agrandir, "Reduire": reduire, "Familier": familier,
          "HumeurHeureux": humeur_heureux, "HumeurContent": humeur_content, "HumeurMecontent": humeur_mecontent}


def main():
    SORTIE.mkdir(parents=True, exist_ok=True)
    for nom, dessin in ICONES.items():
        img = Image.new("RGBA", (TAILLE * SUR, TAILLE * SUR), (255, 255, 255, 0))
        dessin(ImageDraw.Draw(img))
        img = img.resize((TAILLE, TAILLE), Image.LANCZOS)
        img.save(SORTIE / f"{nom}.tga")
    print(f"{len(ICONES)} icônes écrites dans {SORTIE}")


if __name__ == "__main__":
    main()
