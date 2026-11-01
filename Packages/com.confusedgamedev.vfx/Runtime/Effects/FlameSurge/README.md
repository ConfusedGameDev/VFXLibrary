# Surging Flame Tide

Port of **Surging Flame Tide** (`flame-surge`, `kind 3`, `variant 4`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

Broad sheets of flame fold upward like a fan, and their edges scatter into small sparks.

## Usage

Drop `Assets/FlameSurge.prefab` into a scene. It is a one-shot: it plays once and finishes on its own after
3s of effect time, with no `Stop()` ending. Tools > ConfusedGameDev > VFX > Rebuild Surging Flame Tide Assets
regenerates the prefab and meshes.

## Parameters

| Field | Range | Default |
|---|---|---|
| `color` | | `#FF823E` |
| `size` | 0.25 to 2 | 1 |
| `speed` | 0.25 to 2 | 1 |
| `detail` | 0.25 to 2 | 1 |
| `density` | 0.125 to 1 | 0.5 |
| `quantity` | 1 to 10 | 5 |

## Layers

| Layer | Blend | Queue | Notes |
|---|---|---|---|
| Body | alpha | Transparent+2 | Ten rolling tongues, shown by `quantity`, and twelve smoke puffs |
| Particles | alpha | Transparent+3 | 500 quads; twelve slots of the budget go to the puffs, as on the site |

## Known differences from the web version

- Blending happens in linear space here. Compare with tonemapping and bloom off.
