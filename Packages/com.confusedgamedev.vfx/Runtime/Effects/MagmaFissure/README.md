# Molten Vein Fissure

Port of **Molten Vein Fissure** (`magma-fissure`, `kind 3`, `variant 8`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

A glowing crack runs along the ground, heaves dark rocks up on both sides and spits embers.

## Usage

Drop `Assets/MagmaFissure.prefab` into a scene. It is a one-shot: it plays once and finishes on its own after
1.8s of effect time, with no `Stop()` ending. Tools > ConfusedGameDev > VFX > Rebuild Molten Vein Fissure Assets
regenerates the prefab and meshes.

## Parameters

| Field | Range | Default |
|---|---|---|
| `color` | | `#FF823E` |
| `size` | 0.25 to 2 | 1 |
| `speed` | 0.25 to 2 | 1 |
| `detail` | 0.25 to 2 | 1 |
| `density` | 0.125 to 1 | 0.5 |
| `quantity` | 1 to 26 | 13 |

## Layers

| Layer | Blend | Queue | Notes |
|---|---|---|---|
| Body | alpha | Transparent+1 | The crack, its branches and fifty-two rocks, shown by `quantity` |
| Particles | alpha | Transparent+2 | 512 tetrahedra, past-count ones collapse |

## Known differences from the web version

- Blending happens in linear space here. Compare with tonemapping and bloom off.
