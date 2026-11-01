# Vortex Lightning Strike

Port of **Vortex Lightning Strike** (`thunder-strike`, `kind 3`, `variant 5`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

Electric light gathers overhead, a blue-white bolt splits down through it, and the strike throws sparks across the ground.

## Usage

Drop `Assets/ThunderStrike.prefab` into a scene. It is a one-shot: it plays once and finishes on its own after
2.6s of effect time, with no `Stop()` ending. Tools > ConfusedGameDev > VFX > Rebuild Vortex Lightning Strike Assets
regenerates the prefab and meshes.

## Parameters

| Field | Range | Default |
|---|---|---|
| `color` | | `#2878FF` |
| `size` | 0.25 to 2 | 1 |
| `speed` | 0.25 to 2 | 1 |
| `detail` | 0.25 to 2 | 1 |
| `density` | 0.125 to 1 | 0.5 |

## Layers

| Layer | Blend | Queue | Notes |
|---|---|---|---|
| Body | premultiplied | Transparent+2 | Thirty-five strokes for the bolt, its forks and the ground arcs, two flashes, the storm eye and the ground ripple |
| Particles | alpha | Transparent+3 | 512 quads, past-count quads collapse |

## Known differences from the web version

- Blending happens in linear space here. Compare with tonemapping and bloom off.
