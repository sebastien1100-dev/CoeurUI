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


ICONES = {"Copier": copier, "Bas": bas, "Talents": talents, "Heritage": heritage, "Aide": aide, "Courrier": courrier, "Suivi": suivi, "File": file_attente, "Tiroir": tiroir, "Recharger": recharger,
          "Sortie": sortie, "Personnage": personnage, "Metiers": metiers, "Sorts": sorts, "Succes": succes,
          "Quetes": quetes, "Guilde": guilde, "Groupes": groupes, "Collections": collections, "Journal": journal,
          "Boutique": boutique, "Menu": menu, "Logement": logement}


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
