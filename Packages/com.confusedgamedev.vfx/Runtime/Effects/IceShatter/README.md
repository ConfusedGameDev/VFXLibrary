# Shattering Frostburst

Port of **Shattering Frostburst** (`ice-shatter`, `kind 3`, `variant 3`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

A cluster of ice spikes lights up with cracks, then bursts into crystals and small flying chips.

## Usage

Drop `Assets/IceShatter.prefab` into a scene. It is a one-shot: it plays once and finishes on its own after
2.8s of effect time, with no `Stop()` ending. Tools > ConfusedGameDev > VFX > Rebuild Shattering Frostburst Assets
regenerates the prefab and meshes.

## Parameters

| Field | Range | Default |
|---|---|---|
| `color` | | `#B8E5FF` |
| `size` | 0.25 to 2 | 1 |
| `speed` | 0.25 to 2 | 1 |
| `detail` | 0.25 to 2 | 1 |
| `density` | 0.125 to 1 | 0.5 |
| `quantity` | 1 to 18 | 9 |

## Layers

| Layer | Blend | Queue | Notes |
|---|---|---|---|
| Clouds | alpha | Transparent | Frost mist, 108 quads, past-count quads collapse |
| Crystals | alpha | Transparent+2 | Eighteen spikes, shown by `quantity` |
| Shards | alpha | Transparent+2 | Sixty-two octahedra |
| Wave | alpha | Transparent+2 | Ground rings, not scaled by `size`, as on the site |
| Sparks | alpha | Transparent+3 | 768 quads |

## Known differences from the web version

- Blending happens in linear space here. Compare with tonemapping and bloom off.
