# Riftblade Sweep

Port of **Riftblade Sweep** (`spatial-sweep`, `kind 3`, `variant 12`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

A clear blade sweeps almost a full turn around the origin at a height of 1. The scene behind it stretches along the swing and breaks into fast bands, and a thin bright edge leads it, then the tail catches up and the distortion closes.

## Usage

Drop `Assets/SpatialSweep.prefab` into a scene. It is a one-shot: it plays once and finishes on its own after
0.85s of effect time, with no `Stop()` ending. Tools > ConfusedGameDev > VFX > Rebuild Riftblade Sweep Assets
regenerates the prefab and meshes.

## Parameters

| Field | Range | Default |
|---|---|---|
| `color` | | `#E9F5FF` |
| `size` | 0.25 to 2 | 1 |
| `speed` | 0.25 to 2 | 1 |
| `detail` | 0.25 to 2 | 1 |
| `density` | 0.125 to 1 | 0.5 |

## Layers

| Layer | Blend | Queue | Notes |
|---|---|---|---|
| Refraction | alpha, samples the scene | Transparent+1 | The wide clear face |
| Halo | additive | Transparent+2 | Faint light on the rim |
| Streaks | additive | Transparent+3 | 8 speed lines, past-count ones collapse |
| Edge | additive | Transparent+4 | The bright cutting edge |

## Known differences from the web version

- Blending happens in linear space here. Compare with tonemapping and bloom off.
- **Requires the Opaque Texture.** Refraction samples `_CameraOpaqueTexture` where the site samples three.js's transmission capture. Enable Opaque Texture on the URP asset or on the camera. Without it the blade shows black. Transparent objects are not in that texture, so they will not bend.
- On a plain background the blade is nearly invisible apart from its edge, as on the site.
