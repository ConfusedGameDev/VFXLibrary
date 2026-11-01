# Sand-Swept Vortex

Port of **Sand-Swept Vortex** (`dust-devil`, `kind 4`, `variant 1`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

Rolling sand billows and sheets wind upward around an open middle, with grit flying beside them. Its ending lets the sand fall.

## Usage

Drop `Assets/DustDevil.prefab` into a scene. Its origin sits 1.4 units above the ground plane, as on the site. It runs until `Stop()`, then plays its ending. Tools > ConfusedGameDev > VFX > Rebuild Sand-Swept Vortex Assets regenerates the prefab and meshes.

## Parameters

| Field | Range | Default |
|---|---|---|
| `color` | | `#DCBB87` |
| `size` | 0.25 to 2 | 1 |
| `speed` | 0.25 to 2 | 1 |
| `detail` | 0.25 to 2 | 1 |
| `density` | 0.125 to 1 | 0.5 |

Start-up takes 1.7s and the ending 1.4s of effect time.

## Layers

| Layer | Blend | Queue | Notes |
|---|---|---|---|
| Ground | alpha | Transparent | Swirling dust shadow, 7.25 units wide, not scaled by `size` |
| Dust | alpha | Transparent+1 | Up to 96 billboards, 82 by default, range not scaled by `size` |
| Column | alpha | Transparent+2 | 22 ribbon sheets shaped in the vertex shader, ahead of them 22 sand billows |
| Particles | alpha | Transparent+3 | 1024 quads, 380 by default, past-count quads collapse |
| Debris | alpha | Transparent+4 | Grit chips, up to 40, 28 by default |

## Known differences from the web version

- Blending happens in linear space here. Compare with tonemapping and bloom off.
