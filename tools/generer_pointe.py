"""Génère la pointe des bulles de discussion (module « Bulles de discussion »).

Un triangle plein, pointe en bas, blanc sur fond transparent : le jeu le teinte. Il sert deux fois,
l'un sur l'autre : un peu plus grand en gris (le liseré), un peu plus petit à la couleur du fond.

Usage : python tools/generer_pointe.py   (demande Pillow : pip install pillow)
Sortie : CoeurUI/Media/Pointe.tga, 64 x 32 px, TGA 32 bits.
"""

from pathlib import Path

from PIL import Image, ImageDraw

LARGEUR, HAUTEUR = 64, 32
SUR = 8  # suréchantillonnage pour des bords lisses

RACINE = Path(__file__).resolve().parent.parent
SORTIE = RACINE / "CoeurUI" / "Media" / "Pointe.tga"


def main():
    w, h = LARGEUR * SUR, HAUTEUR * SUR
    img = Image.new("RGBA", (w, h), (255, 255, 255, 0))
    ImageDraw.Draw(img).polygon([(0, 0), (w, 0), (w / 2, h)], fill=(255, 255, 255, 255))
    img.resize((LARGEUR, HAUTEUR), Image.LANCZOS).save(SORTIE)
    print(f"Pointe écrite dans {SORTIE}")


if __name__ == "__main__":
    main()
