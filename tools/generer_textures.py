"""Génère les textures du style « Givre » de CœurUI (direction artistique validée le 28/11/2026).

- Ombre.tga (64 x 64) : ombre douce d'un cadre (rectangle arrondi flouté, noir), découpée en neuf
  morceaux par le jeu (marges de 24 px) pour entourer un cadre de n'importe quelle taille.
- Stries.tga (16 x 16) : fines stries en diagonale, blanches et translucides, répétées par le jeu sur
  les barres (vie, ressource, incantation, expérience) ; leur taille ne change pas avec la barre.

Usage : python tools/generer_textures.py   (demande Pillow : pip install pillow)
Sortie : CoeurUI/Media/Ombre.tga, CoeurUI/Media/Stries.tga
"""

from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter

RACINE = Path(__file__).resolve().parent.parent
SORTIE = RACINE / "CoeurUI" / "Media"


def ombre():
    taille, marge, flou = 64, 18, 7
    masque = Image.new("L", (taille, taille), 0)
    ImageDraw.Draw(masque).rounded_rectangle([marge, marge, taille - marge, taille - marge], radius=5, fill=255)
    masque = masque.filter(ImageFilter.GaussianBlur(flou))
    img = Image.new("RGBA", (taille, taille), (0, 0, 0, 0))
    img.putalpha(masque)
    img.save(SORTIE / "Ombre.tga")


def stries():
    taille, sur = 16, 8
    grand = taille * sur
    img = Image.new("RGBA", (grand, grand), (255, 255, 255, 0))
    d = ImageDraw.Draw(img)
    # Deux traits en diagonale par tuile (le motif se raccorde d'une tuile à l'autre).
    epais = 3 * sur
    for decal in (-grand, 0, grand):
        d.line([(decal, grand), (decal + grand, 0)], fill=(255, 255, 255, 255), width=epais)
    for decal in (-grand // 2, grand // 2, grand + grand // 2):
        d.line([(decal, grand), (decal + grand, 0)], fill=(255, 255, 255, 255), width=epais)
    img = img.resize((taille, taille), Image.LANCZOS)
    img.save(SORTIE / "Stries.tga")


def main():
    ombre()
    stries()
    print(f"Ombre.tga et Stries.tga écrites dans {SORTIE}")


if __name__ == "__main__":
    main()
