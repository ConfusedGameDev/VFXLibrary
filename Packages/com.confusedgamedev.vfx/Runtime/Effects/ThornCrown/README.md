# Thornvine Blossom Crown

Port of **Thornvine Blossom Crown** (`thorn-crown`, `kind 2`, `variant 6`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

Thorned vines climb from a leaf sigil, leaves opening along them, around a seven-petalled blossom. In its ending the vines wither back to the ground.

## Usage

Drop `Assets/ThornCrown.prefab` into a scene with its origin on the ground. It runs until `Stop()`, then plays its
one-second ending. Tools > ConfusedGameDev > VFX > Rebuild Thornvine Blossom Crown Assets regenerates the prefab and meshes.

## Parameters

| Field | Range | Default |
|---|---|---|
| `color` | | `#88D49A` |
| `size` | 0.25 to 2 | 1 |
| `speed` | 0.25 to 2 | 1 |
| `detail` | 0.25 to 2 | 1 |
| `density` | 0.125 to 1 | 0.5 |
| `quantity` | 1 to 8 | 4 |

Start-up takes 0.7s and the ending 1s of effect time.

## Layers

| Layer | Blend | Queue | Notes |
|---|---|---|---|
| Sigil | alpha | Transparent | Procedural emblem |
| Body | alpha, ZWrite on | Transparent+2 | Vines, leaves, thorns and blossom, running their own ending |
| Particles | alpha | Transparent+3 | 512 quads, past-count quads collapse |

## Known differences from the web version

- Blending happens in linear space here. Compare with tonemapping and bloom off.
