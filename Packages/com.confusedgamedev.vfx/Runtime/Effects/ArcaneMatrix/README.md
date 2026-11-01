# Floating Rune Matrix

Port of **Floating Rune Matrix** (`arcane-matrix`, `kind 2`, `variant 4`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

Nine crystals with small rings bob over a square lattice and take quarter turns together, while diamonds rise from the lattice crossings. In its ending the crystals sink and the ground cracks into tiles.

## Usage

Drop `Assets/ArcaneMatrix.prefab` into a scene with its origin on the ground. It runs until `Stop()`, then plays its
one-second ending. Tools > ConfusedGameDev > VFX > Rebuild Floating Rune Matrix Assets regenerates the prefab and meshes.

## Parameters

| Field | Range | Default |
|---|---|---|
| `color` | | `#BD9AFF` |
| `size` | 0.25 to 2 | 1 |
| `speed` | 0.25 to 2 | 1 |
| `detail` | 0.25 to 2 | 1 |
| `density` | 0.125 to 1 | 0.5 |
| `quantity` | 1 to 18 | 9 |

Start-up takes 0.7s and the ending 1s of effect time.

## Layers

| Layer | Blend | Queue | Notes |
|---|---|---|---|
| Sigil | alpha | Transparent | Procedural emblem |
| Body | alpha, ZWrite on | Transparent+2 | Lattice, crystals and rings with an ink edge |
| Particles | alpha | Transparent+3 | 512 quads, past-count quads collapse |

## Known differences from the web version

- Blending happens in linear space here. Compare with tonemapping and bloom off.
