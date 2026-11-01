# Ground-Hugging Mist

Port of **Ground-Hugging Mist** (`ground-fog`, `kind 5`, `variant 1`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

Thin mist spreads along the ground, drifting slowly. It can hide what lies low.

## Usage

Drop `Assets/GroundFog.prefab` into a scene. Its origin sits 1.4 units above the ground plane, as on the site. It runs until `Stop()`, then plays its ending. Tools > ConfusedGameDev > VFX > Rebuild Ground-Hugging Mist Assets regenerates the prefab and meshes.

## Parameters

| Field | Range | Default |
|---|---|---|
| `color` | | `#A6C9CA` |
| `size` | 0.25 to 2 | 1 |
| `speed` | 0.25 to 2 | 1 |
| `detail` | 0.25 to 2 | 1 |
| `density` | 0.125 to 1 | 0.5 |

Start-up takes 0.5s and the ending 1.2s of effect time.

## Layers

| Layer | Blend | Queue | Notes |
|---|---|---|---|
| Clouds | alpha | Transparent | 128 lit billboards, 64 by default, past-count quads collapse |

## Known differences from the web version

- Blending happens in linear space here. Compare with tonemapping and bloom off.
