# Sand-Gathering Sigil

Port of **Sand-Gathering Sigil** (`quicksand-seal`, `kind 2`, `variant 7`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

Dunes rise in turn inside a triangular seal and collapse inward, with fine sand streaming along each slide. In its ending the sand sinks into the seal.

## Usage

Drop `Assets/QuicksandSeal.prefab` into a scene with its origin on the ground. It runs until `Stop()`, then plays its
one-second ending. Tools > ConfusedGameDev > VFX > Rebuild Sand-Gathering Sigil Assets regenerates the prefab and meshes.

## Parameters

| Field | Range | Default |
|---|---|---|
| `color` | | `#DFBA7C` |
| `size` | 0.25 to 2 | 1 |
| `speed` | 0.25 to 2 | 1 |
| `detail` | 0.25 to 2 | 1 |
| `density` | 0.125 to 1 | 0.5 |
| `quantity` | 1 to 6 | 3 |

Start-up takes 0.7s and the ending 1s of effect time.

## Layers

| Layer | Blend | Queue | Notes |
|---|---|---|---|
| Sigil | alpha | Transparent | Procedural emblem |
| Body | alpha, ZWrite on | Transparent+2 | Dunes and sliding packets, shaped in the vertex shader |
| Particles | alpha | Transparent+3 | 512 quads, past-count quads collapse |

## Known differences from the web version

- Blending happens in linear space here. Compare with tonemapping and bloom off.
