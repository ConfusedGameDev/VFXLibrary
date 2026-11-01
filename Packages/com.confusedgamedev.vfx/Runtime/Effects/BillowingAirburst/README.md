# Billowing Airburst

Port of **Billowing Airburst** (`billowing-airburst`, `kind 3`, `variant 11`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

A fireball bursts in mid-air behind a blinding flash and a shock ring. Thick jets of rolling fire shoot outward, with torn ribbons and long-tailed embers, then cool from white through orange to soot and erode away. Each cast picks new jets and a new noise offset.

## Usage

Drop `Assets/BillowingAirburst.prefab` into a scene. It is a one-shot: it plays once and finishes on its own after
2.4s of effect time, with no `Stop()` ending. Tools > ConfusedGameDev > VFX > Rebuild Billowing Airburst Assets
regenerates the prefab and meshes.

## Parameters

| Field | Range | Default |
|---|---|---|
| `color` | | `#FF7A24` |
| `size` | 0.25 to 2 | 1 |
| `speed` | 0.25 to 2 | 1 |
| `detail` | 0.25 to 2 | 1 |
| `density` | 0.125 to 1 | 0.5 |
| `quantity` | 2 to 6 | 4 |

## Layers

| Layer | Blend | Queue | Notes |
|---|---|---|---|
| Glow | additive | Transparent | Geometry, drawn before the volumes on purpose |
| Core | opaque | Transparent | Geometry+1, 9 lobes, writes depth |
| Jets | opaque | Transparent | Geometry+1, 24 lobes per jet, writes depth |
| Wave | alpha | Transparent+2 | Billboard pressure ring |
| Arcs | alpha | Transparent+3 | Two torn fire ribbons |
| Flash | additive | Transparent+4 | Launch flash, gone in 90ms |
| Embers | alpha | Transparent+4 | 128 heads, the long ones with trails |

## Known differences from the web version

- Blending happens in linear space here. Compare with tonemapping and bloom off.
- `Play(uint)` replays a cast. `Play()` rolls a new one, like the site.
- The volumes run noise in the vertex shader for about 56,000 vertices. Reduce nothing here without comparing the silhouette.
