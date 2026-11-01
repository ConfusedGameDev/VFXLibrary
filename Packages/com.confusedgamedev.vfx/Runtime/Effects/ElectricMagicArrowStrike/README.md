# Golden-Bladed Lightning Arrow

Port of **Golden-Bladed Lightning Arrow** (`electric-magic-arrow-strike`, `kind 0`, `variant 7`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

A golden arrow with four hooked blades charges inside a turning sigil, wrapped in forking lightning. It flies with crackling trails, and on contact erodes from the tip while a lightning web and two broken shock rings burst from the point of impact.

## Usage

Drop `Assets/ElectricMagicArrowStrike.prefab` into a scene. It charges over 1.2s and holds until the game ends it. Call `SetDirection` to launch it, and `Hit` on contact. `Stop()` fades it without an impact over 1.4s of effect time. The sigil stays in the world where the arrow left it. `Play(uint)` replays a cast with the same lightning; `Play()` picks a new seed. Tools > ConfusedGameDev > VFX > Rebuild Golden-Bladed Lightning Arrow Assets regenerates the prefab and meshes.

## Parameters

| Field | Range | Default |
|---|---|---|
| `color` | | `#FFD36A` |
| `size` | 0.25 to 2 | 1 |
| `speed` | 0.25 to 2 | 1 |
| `detail` | 0.25 to 2 | 1 |
| `density` | 0.125 to 1 | 0.5 |

## Layers

| Layer | Blend | Queue | Notes |
|---|---|---|---|
| Sigil | additive | Transparent+1 | Behind the arrow, locks in world space on release |
| Core | alpha | Transparent+2 | Flat-shaded shaft and blades |
| Halo | additive | Transparent+3 | Three crossed cards |
| Trails | additive | Transparent+3 | Dynamic, shows only in flight |
| Arcs | additive | Transparent+4 | Dynamic, 32 paths |
| Impact | additive | Transparent+4 | Dynamic, 64 paths and two rings, hidden until `Hit` |
| Particles | additive | Transparent+4 | 256 sparks, past-count ones collapse |
| Glow | additive | Transparent+5 | The contact flash, hidden until `Hit` |

The three dynamic layers share one regenerating class, `ElectricArrowDischarge`. It only rewrites a path when that channel's next event starts, and allocates nothing per frame. It runs on the CPU, which is the only part of this effect the size of `density` does not touch.

## Known differences from the web version

- Blending happens in linear space here. Compare with tonemapping and bloom off.
- Lightning is seeded per cast on both sides, so no two views match stroke for stroke.
