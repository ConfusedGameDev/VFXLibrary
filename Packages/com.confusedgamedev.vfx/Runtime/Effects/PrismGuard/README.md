# Prismatic Crystal Bulwark

Port of **Prismatic Crystal Bulwark** (`prism-guard`, `kind 7`, `variant 0`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

Seven hexagonal crystal plates fold out into a curved wall in front of the origin, facing +Z, with faint glints drifting around it.

## Usage

Drop `Assets/PrismGuard.prefab` into a scene. It opens over 0.3s and runs until `Stop()`, then closes over
0.65s of effect time. Tools > ConfusedGameDev > VFX > Rebuild Prismatic Crystal Bulwark Assets regenerates the prefab and meshes.

## Parameters

| Field | Range | Default |
|---|---|---|
| `color` | | `#73E3FF` |
| `size` | 0.25 to 2 | 1 |
| `speed` | 0.25 to 2 | 1 |
| `detail` | 0.25 to 2 | 1 |
| `density` | 0.125 to 1 | 0.5 |
| `quantity` | 1 to 7 | 7 |

## Layers

| Layer | Blend | Queue | Notes |
|---|---|---|---|
| Body | alpha | Transparent+1 | Seven plates with raised insets, shown by `quantity` |
| Particles | alpha | Transparent+2 | 512 tetrahedra, past-count ones collapse |

## Known differences from the web version

- Blending happens in linear space here. Compare with tonemapping and bloom off.
