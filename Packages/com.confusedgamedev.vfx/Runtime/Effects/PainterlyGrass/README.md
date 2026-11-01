# Windswept Meadow

Port of **Windswept Meadow** (`painterly-grass`, `kind 10`, `variant 0`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

A patch of painted grass clumps grows from the ground, dotted with small white flowers. Tips and flowers sway in travelling gusts. Unlike the other effects this one is opaque scenery: it writes depth and draws in the Geometry queue.

## Usage

Drop `Assets/PainterlyGrass.prefab` into a scene. It opens over 0.6s and runs until `Stop()`, then closes over
0.8s of effect time. Tools > ConfusedGameDev > VFX > Rebuild Windswept Meadow Assets regenerates the prefab and meshes.

## Parameters

| Field | Range | Default |
|---|---|---|
| `color` | | `#829544` |
| `size` | 0.25 to 2 | 1 |
| `speed` | 0.25 to 2 | 1 |
| `detail` | 0.25 to 2 | 1 |
| `density` | 0.125 to 1 | 0.75 |

## Layers

| Layer | Blend | Queue | Notes |
|---|---|---|---|
| Blades | opaque | Geometry | 480 clumps of three brush blades, past-count ones collapse |
| Flowers | opaque | Geometry | 32 stems with five petals |

## Known differences from the web version

- Blending happens in linear space here. Compare with tonemapping and bloom off.
- `density` defaults to 0.75 and splits 15 to 1 between blades and flowers. `size` scales the clumps, not the patch, which stays 3.7 units across.
- Both layers have a `DepthOnly` pass so they work with depth priming and the depth texture. They cast no shadows, as on the site.
