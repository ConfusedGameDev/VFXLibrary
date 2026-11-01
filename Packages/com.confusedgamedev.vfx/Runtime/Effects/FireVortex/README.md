# Flame-Swept Vortex

Port of **Flame-Swept Vortex** (`fire-vortex`, `kind 4`, `variant 2`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

Orange flame sheets wind upward and light the dust beneath them. Its ending burns the sheets away to dark embers.

## Usage

Drop `Assets/FireVortex.prefab` into a scene. Its origin sits 1.4 units above the ground plane, as on the site. It runs until `Stop()`, then plays its ending. Tools > ConfusedGameDev > VFX > Rebuild Flame-Swept Vortex Assets regenerates the prefab and meshes.

## Parameters

| Field | Range | Default |
|---|---|---|
| `color` | | `#FF884B` |
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
| Column | alpha | Transparent+2 | 22 ribbon sheets shaped in the vertex shader |
| Particles | alpha | Transparent+3 | 1024 quads, 402 by default, past-count quads collapse |
| Debris | alpha | Transparent+4 | Ember cards, up to 40, 28 by default |

## Known differences from the web version

- Blending happens in linear space here. Compare with tonemapping and bloom off.
