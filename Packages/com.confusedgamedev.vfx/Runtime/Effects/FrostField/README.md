# Sixfold Frost Sigil

Port of **Sixfold Frost Sigil** (`frost-field`, `kind 2`, `variant 2`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

A snowflake sigil lights up outward while six-pointed ice flecks glint just above it. Its ending cracks the ground into tumbling tiles.

## Usage

Drop `Assets/FrostField.prefab` into a scene with its origin on the ground. It runs until `Stop()`, then plays its
one-second ending. Tools > ConfusedGameDev > VFX > Rebuild Sixfold Frost Sigil Assets regenerates the prefab and meshes.

## Parameters

| Field | Range | Default |
|---|---|---|
| `color` | | `#9BDFFF` |
| `size` | 0.25 to 2 | 1 |
| `speed` | 0.25 to 2 | 1 |
| `detail` | 0.25 to 2 | 1 |
| `density` | 0.125 to 1 | 0.5 |

Start-up takes 0.7s and the ending 1s of effect time.

## Layers

| Layer | Blend | Queue | Notes |
|---|---|---|---|
| Aura | additive | Transparent | Ground glow, not scaled by `size`, as on the site |
| Sigil | additive | Transparent+1 | Procedural rings and emblem |
| Particles | additive | Transparent+3 | 512 quads, past-count quads collapse |

## Known differences from the web version

- Blending happens in linear space here. Compare with tonemapping and bloom off.
