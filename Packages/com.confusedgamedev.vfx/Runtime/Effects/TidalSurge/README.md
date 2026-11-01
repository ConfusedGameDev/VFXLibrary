# Breaking Tidal Surge

Port of **Breaking Tidal Surge** (`tidal-surge`, `kind 3`, `variant 6`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

A wall of water pushes outward, its crest folds forward, and its edges break into foam and droplets.

## Usage

Drop `Assets/TidalSurge.prefab` into a scene. It is a one-shot: it plays once and finishes on its own after
3.2s of effect time, with no `Stop()` ending. Tools > ConfusedGameDev > VFX > Rebuild Breaking Tidal Surge Assets
regenerates the prefab and meshes.

## Parameters

| Field | Range | Default |
|---|---|---|
| `color` | | `#66CDDD` |
| `size` | 0.25 to 2 | 1 |
| `speed` | 0.25 to 2 | 1 |
| `detail` | 0.25 to 2 | 1 |
| `density` | 0.125 to 1 | 0.5 |

## Layers

| Layer | Blend | Queue | Notes |
|---|---|---|---|
| Body | alpha | Transparent+2 | The wave sheet, its foam band and twelve spray puffs, with depth writes as on the site |
| Particles | alpha | Transparent+3 | 500 quads; twelve slots of the budget go to the puffs, as on the site |

## Known differences from the web version

- Blending happens in linear space here. Compare with tonemapping and bloom off.
- The wave travels along +Z, where the site sends it along +Z of its own right-handed axes; the port swaps X and Z as every effect here does.
