# Frostcrystal Dart

Port of **Frostcrystal Dart** (`ice-shard`, `kind 0`, `variant 2`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

A faceted cluster of ice lances flying forward, shedding tumbling flecks and thin frost streams. `Hit()` shatters it into spinning crystals.

## Usage

Drop `Assets/IceShard.prefab` into a scene. It flies along `transform.forward`.

```csharp
effect.Play();
effect.SetDirection(aim, speed: 4f);
effect.Hit(contactPoint, contactNormal); // from your collision code
```

`Stop()` ends it without an impact. Tools > ConfusedGameDev > VFX > Rebuild Frostcrystal Dart Assets regenerates the
prefab and meshes.

## Parameters

| Field | Range | Default |
|---|---|---|
| `color` | | `#B3DCFF` |
| `size` | 0.25 to 2 | 1 |
| `speed` | 0.25 to 2 | 1 |
| `detail` | 0.25 to 2 | 1 |
| `density` | 0.125 to 1 | 0.5 |

Start-up takes 0.35s and the ending 0.8s of effect time.

## Layers

| Layer | Blend | Queue | Notes |
|---|---|---|---|
| Core | alpha, ZWrite on | Transparent+2 | Flat-shaded; alpha is 1 while steady |
| Trails | alpha | Transparent+3 | Three frost streams |
| Particles | additive | Transparent+3 | 512 small octahedra, past-count ones collapse |
| Glow | additive | Transparent+4 | Contact flash, first 28% of an impact |
| Impact | alpha | Transparent+5 | 13 crystals |

## Known differences from the web version

- Forward is +Z, not +X. Additive blending happens in linear space here. Compare with tonemapping and bloom off.
- The core keeps ZWrite on during start-up and ending, like the fireball; the site turns it off in those stages.
