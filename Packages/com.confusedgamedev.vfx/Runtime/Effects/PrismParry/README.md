# Prismatic Crystal Block

Port of **Prismatic Crystal Block** (`prism-parry`, `kind 3`, `variant 1`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

A bright cross flashes where the hit lands, small crystal plates buckle and rebound, and shards and sparks scatter outward. The plates face +Z from the origin.

## Usage

Drop `Assets/PrismParry.prefab` into a scene. It is a one-shot: it plays once and finishes on its own after
0.55s of effect time, with no `Stop()` ending. Tools > ConfusedGameDev > VFX > Rebuild Prismatic Crystal Block Assets
regenerates the prefab and meshes.

## Parameters

| Field | Range | Default |
|---|---|---|
| `color` | | `#FFE3A0` |
| `size` | 0.25 to 2 | 1 |
| `speed` | 0.25 to 2 | 1 |
| `detail` | 0.25 to 2 | 1 |
| `density` | 0.125 to 1 | 0.5 |
| `quantity` | 1 to 4 | 4 |

## Layers

| Layer | Blend | Queue | Notes |
|---|---|---|---|
| Body | alpha | Transparent+1 | Four plates shown by `quantity`, nine shards and the contact line |
| Particles | alpha | Transparent+2 | 512 tetrahedra, past-count ones collapse |

## Known differences from the web version

- Blending happens in linear space here. Compare with tonemapping and bloom off.
