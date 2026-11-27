"""Génère les textures du style « Givre » de CœurUI (direction artistique validée le 28/11/2026).

- Ombre.tga (64 x 64) : ombre douce d'un cadre (rectangle arrondi flouté, noir), découpée en neuf
  morceaux par le jeu (marges de 24 px) pour entourer un cadre de n'importe quelle taille.
- Stries.tga (16 x 16) : fines stries en diagonale, blanches et translucides, répétées par le jeu sur
  les barres (vie, ressource, incantation, expérience) ; leur taille ne change pas avec la barre.
- Contour2.tga, Contour3.tga, Contour4.tga (64 x 64) : coin haut gauche d'un liseré arrondi (un quart
  d'anneau, blanc), pour un coin de 2, 3 ou 4 points : affiché à cette taille, le trait fait 1 point.
  Sert aux cadres à fond transparent (le liseré est alors un vrai contour, pas un rectangle plein dessous).

Usage : python tools/generer_textures.py   (demande Pillow : pip install pillow)
Sortie : CoeurUI/Media/Ombre.tga, Stries.tga, Contour2.tga, Contour3.tga, Contour4.tga
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


def contour(rayon):
    taille, sur = 64, 8
    grand = taille * sur
    epais = grand / rayon  # 1 point une fois affiché à rayon x rayon points
    img = Image.new("RGBA", (grand, grand), (255, 255, 255, 0))
    d = ImageDraw.Draw(img)
    # Quart d'anneau centré sur le coin bas droit de l'image : le coin haut gauche d'un cadre.
    d.ellipse([0, 0, 2 * grand, 2 * grand], fill=(255, 255, 255, 255))
    d.ellipse([epais, epais, 2 * grand - epais, 2 * grand - epais], fill=(255, 255, 255, 0))
    img = img.resize((taille, taille), Image.LANCZOS)
    img.save(SORTIE / f"Contour{rayon}.tga")


def main():
    ombre()
    stries()
    for rayon in (2, 3, 4):
        contour(rayon)
    print(f"Ombre.tga, Stries.tga et Contour2-4.tga écrites dans {SORTIE}")


if __name__ == "__main__":
    main()
