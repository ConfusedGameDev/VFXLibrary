# Dust-Raising Shockwave

Port of **Dust-Raising Shockwave** (`shockwave`, `kind 3`, `variant 2`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

A ring of dust punches outward, rolls up in large billows, and small stones fall back to the ground. The last 1.26s of the dust, sparks and stones ripple and break up.

## Usage

Drop `Assets/Shockwave.prefab` into a scene. It is a one-shot: it plays once and finishes on its own after
2.8s of effect time, with no `Stop()` ending. Tools > ConfusedGameDev > VFX > Rebuild Dust-Raising Shockwave Assets
regenerates the prefab and meshes.

## Parameters

| Field | Range | Default |
|---|---|---|
| `color` | | `#F0CF9D` |
| `size` | 0.25 to 2 | 1 |
| `speed` | 0.25 to 2 | 1 |
| `detail` | 0.25 to 2 | 1 |
| `density` | 0.125 to 1 | 0.5 |

## Layers

| Layer | Blend | Queue | Notes |
|---|---|---|---|
| Clouds | alpha | Transparent | Low dust, 72 quads, past-count quads collapse |
| Roll | alpha | Transparent+1 | Seven fixed billows, not reduced by `density` |
| Fans | alpha | Transparent+2 | Eighteen rising dust fans |
| Wave | alpha | Transparent+2 | Ground ring, not scaled by `size`, as on the site |
| Sparks | alpha | Transparent+3 | 512 quads |
| Chips | alpha | Transparent+3 | Twenty-eight tumbling stones |

## Known differences from the web version

- Blending happens in linear space here. Compare with tonemapping and bloom off.
