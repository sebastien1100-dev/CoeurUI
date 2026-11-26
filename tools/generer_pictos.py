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


ICONES = {"Courrier": courrier, "Suivi": suivi, "File": file_attente, "Tiroir": tiroir}


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
