"""Génère les textures de l'icône CœurUI pour le jeu (TGA 32 bits, puissance de 2).

Redessine l'icône à partir des mesures relevées sur la maquette tools/source/Icônes@2x.png
(on ne découpe pas la planche : ce serait flou et entouré de fond).

Usage : python tools/generer_icones.py
Demande Pillow (pip install pillow).

Sorties dans CoeurUI/Media/ :
- Icone.tga           128 px, version A (C + cœur + « UI », carré arrondi, contour doré) : liste des addons.
- IconeMinicarte.tga   64 px, rond, C + cœur sans « UI » : futur bouton de minicarte.
- Logo.tga             64 px, C + cœur sans fond : barre de titre des fenêtres.
- Cercle.tga           32 px, disque blanc : coins arrondis des cadres.
- Engrenage.tga        32 px, engrenage blanc : entrée « Paramètres » de la fenêtre.
- BarreLisse.tga       128 x 32, texture de barre « Lisse (CœurUI) » (blanc ombré, teinté dans le jeu).
- Cadenas.tga / CadenasOuvert.tga   32 px : bouton « Déverrouiller les cadres ».
"""

import math
from pathlib import Path

from PIL import Image, ImageDraw

# Couleurs relevées sur la maquette (thème par défaut, voir CLAUDE.md).
OR = (0xD9, 0xAE, 0x5B, 255)
COEUR = (0xD2, 0x46, 0x5A, 255)
GRAPHITE = (0x2A, 0x2D, 0x34, 255)
BLANC = (0xFF, 0xFF, 0xFF, 255)

SURECHANTILLON = 8  # on dessine 8 fois plus grand puis on réduit, pour des bords lisses

RACINE = Path(__file__).resolve().parent.parent
SORTIE = RACINE / "CoeurUI" / "Media"


def boite(t, x0, y0, x1, y1):
    """Coordonnées relatives (0..1) vers pixels."""
    return [x0 * t, y0 * t, x1 * t, y1 * t]


def dessiner_c(d, t, cx, cy, r_ext, r_int, debut, fin, bout_debut=True, bout_fin=True):
    """Anneau ouvert (le C), de l'angle debut à l'angle fin (degrés, sens horaire, 0 = à droite),
    avec des bouts arrondis."""
    largeur = (r_ext - r_int) * t
    d.arc(boite(t, cx - r_ext, cy - r_ext, cx + r_ext, cy + r_ext), debut, fin, fill=OR, width=round(largeur))
    r_mil = (r_ext + r_int) / 2
    r_bout = (r_ext - r_int) / 2
    for angle, actif in ((debut, bout_debut), (fin, bout_fin)):
        if actif:
            a = math.radians(angle)
            bx, by = cx + r_mil * math.cos(a), cy + r_mil * math.sin(a)
            d.ellipse(boite(t, bx - r_bout, by - r_bout, bx + r_bout, by + r_bout), fill=OR)


def dessiner_coeur(img, t, x0, y0, x1, y1):
    """Cœur à lobes ronds et flancs droits (carré sur la pointe + deux disques),
    étiré dans la boîte donnée."""
    a = 1000  # côté du carré, en pixels de travail
    h = a / math.sqrt(2)
    larg, haut = round(h + a), round(h / 2 + a / 2 + h)
    cx, cy = larg / 2, h / 2 + a / 2  # centre du carré
    m = Image.new("L", (larg, haut), 0)
    d = ImageDraw.Draw(m)
    d.polygon([(cx, cy - h), (cx + h, cy), (cx, cy + h), (cx - h, cy)], fill=255)
    for sx in (-1, 1):
        lx, ly = cx + sx * h / 2, cy - h / 2
        d.ellipse([lx - a / 2, ly - a / 2, lx + a / 2, ly + a / 2], fill=255)
    bx0, by0 = round(x0 * t), round(y0 * t)
    m = m.resize((round(x1 * t) - bx0, round(y1 * t) - by0), Image.LANCZOS)
    img.paste(COEUR, (bx0, by0), m)


def masque_ui(t, marge=0.0):
    """Masque des lettres « UI » de la version A (lettres grasses, U à fond arrondi).
    marge > 0 : lettres grossies d'autant, coins arrondis (sert au liseré)."""
    m = Image.new("L", (t, t), 0)
    d = ImageDraw.Draw(m)
    haut, bas = 0.4775 - marge, 0.705 + marge
    # U : rectangle à fond arrondi, moins son creux.
    ux0, ux1, trait = 0.55 - marge, 0.74 + marge, 0.0525 + marge
    d.rounded_rectangle(boite(t, ux0, haut, ux1, bas), radius=(ux1 - ux0) / 2 * t, fill=255,
                        corners=(False, False, True, True))
    if marge:
        d.rounded_rectangle(boite(t, ux0, haut, ux1, haut + 0.2), radius=marge * t, fill=255,
                            corners=(True, True, False, False))
    ix0, ix1 = ux0 + trait, ux1 - trait
    d.rounded_rectangle(boite(t, ix0, haut - 0.2, ix1, bas - trait), radius=(ix1 - ix0) / 2 * t, fill=0,
                        corners=(False, False, True, True))
    # I
    d.rounded_rectangle(boite(t, 0.765 - marge, haut, 0.8175 + marge, bas), radius=marge * t, fill=255)
    return m


def icone_a(taille):
    """Version A : carré arrondi graphite, contour doré, C + cœur + « UI »."""
    t = taille * SURECHANTILLON
    img = Image.new("RGBA", (t, t), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)

    contour, rayon = 0.012, 0.22
    d.rounded_rectangle(boite(t, 0, 0, 1, 1), radius=rayon * t, fill=OR)
    d.rounded_rectangle(boite(t, contour, contour, 1 - contour, 1 - contour), radius=(rayon - contour) * t,
                        fill=GRAPHITE)

    dessiner_c(d, t, 0.408, 0.505, 0.261, 0.178, 40, 330, bout_debut=False)
    dessiner_coeur(img, t, 0.28, 0.405, 0.59, 0.65)

    # « UI » blanc, détouré d'un liseré graphite qui coupe le C et le cœur.
    img.paste(GRAPHITE, mask=masque_ui(t, marge=0.024))
    img.paste(BLANC, mask=masque_ui(t))

    return img.resize((taille, taille), Image.LANCZOS)


MARGE_MINICARTE = 4  # px transparents autour du rond (sur 64) : voir icone_minicarte


def icone_minicarte(taille):
    """Bouton de minicarte : rond graphite, contour doré, C + cœur sans « UI ».
    Le rond est entouré d'une marge transparente de MARGE_MINICARTE px : les addons de
    minicarte qui rangent les boutons rognent souvent les bords de l'icône (5 % pour
    EllesmereUIMinimap). Le jeu affiche l'icône sans la marge (SetTexCoord dans le module)."""
    rond = _rond_minicarte(taille - 2 * MARGE_MINICARTE)
    img = Image.new("RGBA", (taille, taille), (0, 0, 0, 0))
    img.paste(rond, (MARGE_MINICARTE, MARGE_MINICARTE))
    return img


def _rond_minicarte(taille):
    t = taille * SURECHANTILLON
    img = Image.new("RGBA", (t, t), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)

    contour = 0.03
    d.ellipse(boite(t, 0, 0, 1, 1), fill=OR)
    d.ellipse(boite(t, contour, contour, 1 - contour, 1 - contour), fill=GRAPHITE)

    dessiner_c(d, t, 0.515, 0.505, 0.25, 0.161, 42, 318)
    dessiner_coeur(img, t, 0.38, 0.40, 0.675, 0.645)

    return img.resize((taille, taille), Image.LANCZOS)


def logo(taille):
    """Logo seul, sans fond : C + cœur (barre de titre des fenêtres)."""
    t = taille * SURECHANTILLON
    img = Image.new("RGBA", (t, t), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    dessiner_c(d, t, 0.495, 0.5, 0.47, 0.30, 42, 318)
    dessiner_coeur(img, t, 0.24, 0.30, 0.795, 0.762)
    return img.resize((taille, taille), Image.LANCZOS)


def cercle(taille):
    """Disque blanc : ses quarts servent de coins arrondis aux cadres (teinté dans le jeu)."""
    t = taille * SURECHANTILLON
    img = Image.new("RGBA", (t, t), (255, 255, 255, 0))
    ImageDraw.Draw(img).ellipse([0, 0, t - 1, t - 1], fill=(255, 255, 255, 255))
    return img.resize((taille, taille), Image.LANCZOS)


def engrenage(taille):
    """Engrenage blanc à 8 dents, trou au centre (entrée « Paramètres », teinté dans le jeu)."""
    t = taille * SURECHANTILLON
    img = Image.new("RGBA", (t, t), (255, 255, 255, 0))
    d = ImageDraw.Draw(img)
    c = t / 2
    r_corps, r_dent, demi_dent = 0.34 * t, 0.47 * t, 0.085 * t
    for i in range(8):
        a = math.radians(i * 45)
        ux, uy = math.cos(a), math.sin(a)   # le long de la dent
        vx, vy = -uy, ux                     # en travers
        pts = []
        for along, across in ((r_corps * 0.8, -demi_dent), (r_dent, -demi_dent * 0.8),
                              (r_dent, demi_dent * 0.8), (r_corps * 0.8, demi_dent)):
            pts.append((c + ux * along + vx * across, c + uy * along + vy * across))
        d.polygon(pts, fill=(255, 255, 255, 255))
    d.ellipse([c - r_corps, c - r_corps, c + r_corps, c + r_corps], fill=(255, 255, 255, 255))
    r_trou = 0.15 * t
    d.ellipse([c - r_trou, c - r_trou, c + r_trou, c + r_trou], fill=(255, 255, 255, 0))
    return img.resize((taille, taille), Image.LANCZOS)


def barre_lisse(largeur, hauteur):
    """Texture de barre « Lisse (CœurUI) » : blanc légèrement ombré de haut en bas (teinté dans le jeu)."""
    img = Image.new("RGBA", (largeur, hauteur))
    px = img.load()
    for y in range(hauteur):
        t = y / (hauteur - 1)
        # Reflet en haut, puis descente douce vers le bas.
        v = 1.0 - 0.28 * t + (0.06 if t < 0.15 else 0.0)
        g = max(0, min(255, round(255 * v)))
        for x in range(largeur):
            px[x, y] = (g, g, g, 255)
    return img


def cadenas(taille, ouvert):
    """Cadenas blanc (fermé ou ouvert) pour le bouton « Déverrouiller les cadres »."""
    t = taille * SURECHANTILLON
    img = Image.new("RGBA", (t, t), (255, 255, 255, 0))
    d = ImageDraw.Draw(img)
    # Corps.
    d.rounded_rectangle([0.14 * t, 0.46 * t, 0.86 * t, 0.94 * t], radius=0.1 * t, fill=(255, 255, 255, 255))
    # Anse : arc du haut et deux montants ; ouverte, le montant droit est retiré et l'anse remonte.
    epais = round(0.12 * t)
    haut = 0.04 * t if not ouvert else -0.04 * t
    d.arc([0.27 * t, haut, 0.73 * t, haut + 0.5 * t], 180, 360, fill=(255, 255, 255, 255), width=epais)
    gx = 0.27 * t
    d.rectangle([gx, haut + 0.25 * t, gx + epais, 0.5 * t], fill=(255, 255, 255, 255))
    if not ouvert:
        dx = 0.73 * t - epais
        d.rectangle([dx, haut + 0.25 * t, dx + epais, 0.5 * t], fill=(255, 255, 255, 255))
    return img.resize((taille, taille), Image.LANCZOS)


def main():
    SORTIE.mkdir(parents=True, exist_ok=True)
    for nom, image in (
        ("Icone.tga", icone_a(128)),
        ("IconeMinicarte.tga", icone_minicarte(64)),
        ("Logo.tga", logo(64)),
        ("Cercle.tga", cercle(32)),
        ("Engrenage.tga", engrenage(32)),
        ("BarreLisse.tga", barre_lisse(128, 32)),
        ("Cadenas.tga", cadenas(32, False)),
        ("CadenasOuvert.tga", cadenas(32, True)),
    ):
        chemin = SORTIE / nom
        image.save(chemin, compression=None)  # TGA 32 bits non compressé
        print(f"{chemin.relative_to(RACINE)}  {image.width}x{image.height}")


if __name__ == "__main__":
    main()
