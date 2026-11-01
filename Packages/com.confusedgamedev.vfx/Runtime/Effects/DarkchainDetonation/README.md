# Darkchain Sigil Rupture

Port of **Darkchain Sigil Rupture** (`darkchain-detonation`, `kind 2`, `variant 14`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

Two sigils open, twelve chains lash between them, and ink, smoke and sparks spiral into a black orb that pulses thirty times. It collapses, then detonates: jets, lightning, torn pressure sheets and a black shock ring throw the chains apart, and the scene behind ripples.

## Usage

Drop `Assets/DarkchainDetonation.prefab` into a scene. It is a one-shot: it plays once and finishes on its own after
5.15s of effect time, with no `Stop()` ending. Tools > ConfusedGameDev > VFX > Rebuild Darkchain Sigil Rupture Assets
regenerates the prefab and meshes.

## Parameters

| Field | Range | Default |
|---|---|---|
| `color` | | `#8300FF` |
| `size` | 0.25 to 2 | 1 |
| `speed` | 0.25 to 2 | 1 |
| `detail` | 0.25 to 2 | 1 |
| `density` | 0.125 to 1 | 0.5 |

## Layers

| Layer | Blend | Queue | Notes |
|---|---|---|---|
| Sigil0, Sigil1 | alpha | Transparent+1 | The floor and ceiling circles, with 24 glyphs of runes |
| ChainBody | opaque, stochastic | Geometry | Twelve strands of black links, which break into fragments |
| ChainGlow | additive | Transparent+3 | The links' violet halo |
| RootSeals | additive | Transparent+3 | A seal where each strand lands |
| OrbBody | opaque, stochastic | Geometry | The black core |
| OrbHalo | additive | Transparent+2 | Its halo, then the release flash |
| OrbArcs | additive | Transparent+4 | Six short forked discharges |
| FieldLightning | alpha | Transparent+4 | 36 fine bolts, omnidirectional at release |
| BlackAura, InwardRibbons | alpha | Transparent+2 | Ink strokes spiralling in |
| InwardParticles, Debris | alpha | Transparent+5 | Dark shards, in and out |
| BlastInk, Blast | alpha, additive | Transparent+4, +6 | 252 flow ribbons |
| EnergySurface, EnergyGlow | alpha, additive | Transparent+5, +6 | Four torn pressure sheets |
| CoreEjection | additive | Transparent+6 | 32 streaks that shed sparks |
| ReleasePlasma | alpha | Transparent+3 | The short connected flash |
| ImpactGlints | additive | Transparent+7 | The four-point star and 18 glints |
| AfterSmoke | alpha | Transparent+3 | Soft smoke after the blast |
| Refraction | alpha, samples the scene | Transparent | The screen ripple |
| ShockRing | alpha | Transparent+7 | The black brush ring |
| GroundSmoke, SmokeTails | alpha | Transparent+2, +1 | Six puffs that run the floor and lift into the orb |

## Known differences from the web version

- Blending happens in linear space here. Compare with tonemapping and bloom off.
- **Requires the Opaque Texture.** The `Refraction` layer samples `_CameraOpaqueTexture` where the site samples three.js's transmission capture. Enable Opaque Texture on the URP asset or on the camera. Without it a dark disc shows behind the blast for up to 1.5s. Transparent objects are not in that texture, so they will not bend. `ChainBody` and `OrbBody` are opaque, so they do.
- Each layer keeps the source's time window in its vertex shader, so nothing has to toggle renderers. Orb and field discharges work out their flash clock in the vertex shader instead of a uniform array, and the 24 glyphs are a constant table, so every layer stays on one cbuffer. `DarkchainMotion` is the only per-frame C#, and it does not allocate.
