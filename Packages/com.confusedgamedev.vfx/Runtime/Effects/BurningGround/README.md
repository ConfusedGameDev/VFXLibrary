# Flame-Etched Ground

Port of **Flame-Etched Ground** (`burning-ground`, `kind 2`, `variant 1`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

A five-bladed flame wheel turns over glowing cracks while tongues of fire lick up and die away. Its ending burns the ground out to ash, and unlike the frozen sigils it keeps moving as it does.

## Usage

Drop `Assets/BurningGround.prefab` into a scene with its origin on the ground. It runs until `Stop()`, then plays its
one-second ending. Tools > ConfusedGameDev > VFX > Rebuild Flame-Etched Ground Assets regenerates the prefab and meshes.

## Parameters

| Field | Range | Default |
|---|---|---|
| `color` | | `#FF914A` |
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
| Particles | additive | Transparent+3 | 1024 quads, past-count quads collapse |

## Known differences from the web version

- Blending happens in linear space here. Compare with tonemapping and bloom off.
