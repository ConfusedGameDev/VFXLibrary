# Azure Blade Sweep

Port of **Azure Blade Sweep** (`azure-sweep`, `kind 3`, `variant 10`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

A blue-white blade of light sweeps almost a full turn around the origin at a height of 1, holds for a moment, and its tail runs up and swallows the head.

## Usage

Drop `Assets/AzureSweep.prefab` into a scene. It is a one-shot: it plays once and finishes on its own after
0.85s of effect time, with no `Stop()` ending. Tools > ConfusedGameDev > VFX > Rebuild Azure Blade Sweep Assets
regenerates the prefab and meshes.

## Parameters

| Field | Range | Default |
|---|---|---|
| `color` | | `#2878FF` |
| `size` | 0.25 to 2 | 1 |
| `speed` | 0.25 to 2 | 1 |
| `detail` | 0.25 to 2 | 1 |
| `density` | 0.125 to 1 | 0.5 |

## Layers

| Layer | Blend | Queue | Notes |
|---|---|---|---|
| Blade | alpha | Transparent+1 | The wide inner face |
| Halo | additive | Transparent+2 | Soft light on the outer rim |
| Streaks | additive | Transparent+3 | 12 thin speed lines, past-count ones collapse |
| Edge | additive | Transparent+4 | The bright cutting edge |

## Known differences from the web version

- Blending happens in linear space here. Compare with tonemapping and bloom off.
