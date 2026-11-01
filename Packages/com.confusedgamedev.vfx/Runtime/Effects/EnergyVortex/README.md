# Runic Ring Vortex

Port of **Runic Ring Vortex** (`energy-vortex`, `kind 4`, `variant 3`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

Glowing bands wind upward, with charge running along them, while rune motes ride rings up the open middle.

## Usage

Drop `Assets/EnergyVortex.prefab` into a scene. Its origin sits 1.4 units above the ground plane, as on the site. It runs until `Stop()`, then plays its ending. Tools > ConfusedGameDev > VFX > Rebuild Runic Ring Vortex Assets regenerates the prefab and meshes.

## Parameters

| Field | Range | Default |
|---|---|---|
| `color` | | `#BBA5FF` |
| `size` | 0.25 to 2 | 1 |
| `speed` | 0.25 to 2 | 1 |
| `detail` | 0.25 to 2 | 1 |
| `density` | 0.125 to 1 | 0.5 |

Start-up takes 1.7s and the ending 1.4s of effect time.

## Layers

| Layer | Blend | Queue | Notes |
|---|---|---|---|
| Ground | alpha | Transparent | Swirling dust shadow, 7.25 units wide, not scaled by `size` |
| Dust | alpha | Transparent+1 | Up to 96 billboards, 61 by default, range not scaled by `size` |
| Column | alpha | Transparent+2 | 18 ribbon sheets shaped in the vertex shader |
| Particles | alpha | Transparent+3 | 768 quads, 302 by default, past-count quads collapse |
| Debris | alpha | Transparent+4 | Diamond runes, up to 40, 21 by default |

## Known differences from the web version

- Blending happens in linear space here. Compare with tonemapping and bloom off.
