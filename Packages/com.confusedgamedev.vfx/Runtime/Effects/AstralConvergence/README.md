# Astral Ring Detonation

Port of **Astral Ring Detonation** (`astral-convergence`, `kind 3`, `variant 7`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

Starlight circles inward, shrinks to one point, then bursts outward and leaves shining streaks.

## Usage

Drop `Assets/AstralConvergence.prefab` into a scene. It is a one-shot: it plays once and finishes on its own after
3.4s of effect time, with no `Stop()` ending. Tools > ConfusedGameDev > VFX > Rebuild Astral Ring Detonation Assets
regenerates the prefab and meshes.

## Parameters

| Field | Range | Default |
|---|---|---|
| `color` | | `#C1B8FF` |
| `size` | 0.25 to 2 | 1 |
| `speed` | 0.25 to 2 | 1 |
| `detail` | 0.25 to 2 | 1 |
| `density` | 0.125 to 1 | 0.5 |
| `quantity` | 1 to 20 | 10 |

## Layers

| Layer | Blend | Queue | Notes |
|---|---|---|---|
| Body | alpha | Transparent+2 | Three orbits, a constellation of twelve stars and twenty beams, shown by `quantity` |
| Particles | alpha | Transparent+3 | 512 quads, past-count quads collapse |

## Known differences from the web version

- Blending happens in linear space here. Compare with tonemapping and bloom off.
