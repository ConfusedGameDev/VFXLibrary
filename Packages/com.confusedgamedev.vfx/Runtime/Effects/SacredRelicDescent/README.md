# Sacred Relic Descent

Port of **Sacred Relic Descent** (`sacred-relic-descent`, `kind 2`, `variant 18`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

A white-gold sigil of five layers draws itself and turns. A pyramid relic falls from above and buries its tip, with a water-like shock, cracks, rocks and dust. Then five healing waves roll out two seconds apart, each with a raised ring of smoke. It only draws: no healing, collision, terrain or camera work.

## Usage

Drop `Assets/SacredRelicDescent.prefab` into a scene. It is a one-shot: it plays once and finishes on its own after
13s of effect time. Tools > ConfusedGameDev > VFX > Rebuild Sacred Relic Descent Assets
regenerates the prefab and meshes.

## Parameters

| Field | Range | Default |
|---|---|---|
| `color` | | `#F5CC75` |
| `size` | 0.25 to 2 | 1 |
| `speed` | 0.25 to 2 | 1 |
| `detail` | 0.25 to 2 | 1 |
| `density` | 0.125 to 1 | 0.5 |
| `spread` | 0.5 to 1.5 | 1 |

## Layers

| Layer | Blend | Queue | Notes |
|---|---|---|---|
| Cracks | alpha | Transparent | Dark fissures around the contact |
| Sigil | additive | Transparent+1 | Plain One One, a procedural fragment shader |
| Impact | additive | Transparent+2 | Water-like shock front |
| Echo | additive | Transparent+2 | Trailing ground ring |
| Wave | additive | Transparent+3 | Crested radial strip |
| Debris | alpha | Transparent+4 | 240 rocks, scaled by density |
| Dust | alpha | Transparent+5 | 32 puffs, scaled by density |
| Relic | alpha | Transparent+6 | Writes depth, cut at the ground |
| Trail | alpha | Transparent+7 | Fall streak |
| Smoke | additive | Transparent+8 | 48 sprites, density never removes them |
| Motes | alpha | Transparent+9 | 96 rising motes, scaled by density |

## Known differences from the web version

- Blending happens in linear space here. Compare with tonemapping and bloom off.
- `Stop()` and `Hit()` prevent new pulses and fade everything in 0.45s, as on the site. There is a stop here, unlike the other bursts.
- The site's `setObject`, which swaps the pyramid for a loaded model, is not ported.
- The smoke ring is added in linear space, so its soft overlaps are slightly brighter.
