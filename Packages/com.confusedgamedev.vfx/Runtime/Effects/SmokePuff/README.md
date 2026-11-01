# Dispersing Smoke Puff

Port of **Dispersing Smoke Puff** (`smoke-puff`, `kind 5`, `variant 3`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

A puff of smoke swells fast, then clears. It suits appearing, vanishing or landing.

## Usage

Drop `Assets/SmokePuff.prefab` into a scene. It is a one-shot: it plays once and finishes on its own after 3.5s of effect time, with no `Stop()` ending. Tools > ConfusedGameDev > VFX > Rebuild Dispersing Smoke Puff Assets regenerates the prefab and meshes.

## Parameters

| Field | Range | Default |
|---|---|---|
| `color` | | `#B1AFC8` |
| `size` | 0.25 to 2 | 1 |
| `speed` | 0.25 to 2 | 1 |
| `detail` | 0.25 to 2 | 1 |
| `density` | 0.125 to 1 | 0.5 |

It fades in over 0.15s and clears across its 3.5s.

## Layers

| Layer | Blend | Queue | Notes |
|---|---|---|---|
| Clouds | alpha | Transparent | 96 lit billboards, 48 by default, past-count quads collapse |

## Known differences from the web version

- Blending happens in linear space here. Compare with tonemapping and bloom off.
