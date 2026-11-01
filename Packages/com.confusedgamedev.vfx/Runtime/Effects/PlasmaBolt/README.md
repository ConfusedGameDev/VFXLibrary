# Plasma Dart

Port of **Plasma Dart** (`plasma-bolt`, `kind 0`, `variant 1`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

A bright dart wrapped in jittering electric ribbons, with thin sparks behind it. `Hit()` ends it in a branching discharge.

## Usage

Drop `Assets/PlasmaBolt.prefab` into a scene. It flies along `transform.forward`.

```csharp
effect.Play();
effect.SetDirection(aim, speed: 4f);
effect.Hit(contactPoint, contactNormal); // from your collision code
```

`Stop()` ends it without an impact. Tools > ConfusedGameDev > VFX > Rebuild Plasma Dart Assets regenerates the
prefab and meshes.

## Parameters

| Field | Range | Default |
|---|---|---|
| `color` | | `#73E3FF` |
| `size` | 0.25 to 2 | 1 |
| `speed` | 0.25 to 2 | 1 |
| `detail` | 0.25 to 2 | 1 |
| `density` | 0.125 to 1 | 0.5 |

Start-up takes 0.35s and the ending 0.8s of effect time.

## Layers

| Layer | Blend | Queue | Notes |
|---|---|---|---|
| Halo | additive | Transparent+1 | Camera-facing sheet along the flight axis |
| Core | additive | Transparent+2 | Baked tip |
| Trails | additive | Transparent+3 | Five ribbons, baked as IDs and shaped in the vertex shader |
| Envelope | additive | Transparent+3 | Six ribbons with forks, scales with `size` |
| Particles | additive | Transparent+3 | 512 quads, past-count quads collapse |
| Glow | additive | Transparent+4 | Contact flash, first 28% of an impact |
| Impact | additive | Transparent+5 | 12 bolts, 12 forks, 6 sparks |

## Known differences from the web version

- Forward is +Z, not +X. Additive blending happens in linear space here. Compare with tonemapping and bloom off.
