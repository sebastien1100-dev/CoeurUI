"""Génère les masques de la minicarte rectangulaire (module « Minicarte »).

La carte du jeu reste un carré (sinon le terrain glisse sous la flèche du joueur quand on zoome) :
pour la montrer en rectangle, un masque cache une bande en haut et en bas (Masque_H_k) ou à gauche
et à droite (Masque_V_k). k va de 1 à 22 : chaque bande fait k/64 du côté du carré.

TGA 32 bits non compressé, 128 px (blanc opaque = visible, transparent = caché). Sans Pillow.

Usage : python tools/generer_masques.py
Sortie : CoeurUI/Media/Minicarte/
"""

import struct
from pathlib import Path

TAILLE = 128
PAS = TAILLE // 64  # une bande de k/64 du côté = k * PAS pixels
K_MAX = 22

RACINE = Path(__file__).resolve().parent.parent
SORTIE = RACINE / "CoeurUI" / "Media" / "Minicarte"


def ecrire_tga(chemin, visible):
    """visible(x, y) -> bool ; écrit une image TAILLE x TAILLE en BGRA."""
    entete = struct.pack("<BBBHHBHHHHBB", 0, 0, 2, 0, 0, 0, 0, 0, TAILLE, TAILLE, 32, 8)
    pixels = bytearray()
    for y in range(TAILLE):
        for x in range(TAILLE):
            pixels += b"\xff\xff\xff\xff" if visible(x, y) else b"\xff\xff\xff\x00"
    chemin.write_bytes(entete + bytes(pixels))


def main():
    SORTIE.mkdir(parents=True, exist_ok=True)
    for k in range(1, K_MAX + 1):
        bande = k * PAS
        ecrire_tga(SORTIE / f"Masque_H_{k}.tga", lambda x, y: bande <= y < TAILLE - bande)
        ecrire_tga(SORTIE / f"Masque_V_{k}.tga", lambda x, y: bande <= x < TAILLE - bande)
    print(f"{2 * K_MAX} masques écrits dans {SORTIE}")


if __name__ == "__main__":
    main()
