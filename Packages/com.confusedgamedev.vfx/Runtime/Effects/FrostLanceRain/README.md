# Falling Frost Spear Array

Port of **Falling Frost Spear Array** (`frost-lance-rain`, `kind 3`, `variant 10`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

Ice lances drop from the sky one after another, shatter on landing and leave patches of frost.

## Usage

Drop `Assets/FrostLanceRain.prefab` into a scene. It is a one-shot: it plays once and finishes on its own after
2.4s of effect time, with no `Stop()` ending. Tools > ConfusedGameDev > VFX > Rebuild Falling Frost Spear Array Assets
regenerates the prefab and meshes.

## Parameters

| Field | Range | Default |
|---|---|---|
| `color` | | `#A9DFFF` |
| `size` | 0.25 to 2 | 1 |
| `speed` | 0.25 to 2 | 1 |
| `detail` | 0.25 to 2 | 1 |
| `density` | 0.125 to 1 | 0.5 |
| `quantity` | 1 to 18 | 9 |
| `spread` | 0.5 to 3 | 1 |

## Layers

| Layer | Blend | Queue | Notes |
|---|---|---|---|
| Body | alpha | Transparent+1 | Eighteen landings of a lance, three shards and a frost patch, shown by `quantity` |
| Particles | alpha | Transparent+2 | 512 tetrahedra, past-count ones collapse |

## Known differences from the web version

- Blending happens in linear space here. Compare with tonemapping and bloom off.
