# Bubbling Venom Sigil

Port of **Bubbling Venom Sigil** (`venom-pool`, `kind 2`, `variant 8`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

Bubbles swell and burst on a three-lobed pool, each throwing a spray of droplets, with low mist drifting over it. In its ending every bubble pops in turn.

## Usage

Drop `Assets/VenomPool.prefab` into a scene with its origin on the ground. It runs until `Stop()`, then plays its
one-second ending. Tools > ConfusedGameDev > VFX > Rebuild Bubbling Venom Sigil Assets regenerates the prefab and meshes.

## Parameters

| Field | Range | Default |
|---|---|---|
| `color` | | `#ACDC6F` |
| `size` | 0.25 to 2 | 1 |
| `speed` | 0.25 to 2 | 1 |
| `detail` | 0.25 to 2 | 1 |
| `density` | 0.125 to 1 | 0.5 |
| `quantity` | 1 to 14 | 7 |

Start-up takes 0.7s and the ending 1s of effect time.

## Layers

| Layer | Blend | Queue | Notes |
|---|---|---|---|
| Sigil | alpha | Transparent | Procedural emblem |
| Body | alpha | Transparent+2 | Fourteen thin bubbles, front faces only |
| Particles | alpha | Transparent+3 | 512 quads, past-count quads collapse |
| Mist | alpha | Transparent+4 | 32 quads, sharing the particle budget |

## Known differences from the web version

- Blending happens in linear space here. Compare with tonemapping and bloom off.
