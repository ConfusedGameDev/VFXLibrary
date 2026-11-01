# Crystal-Toothed Ice Wheel

Port of **Crystal-Toothed Ice Wheel** (`frost-wheel`, `kind 0`, `variant 4`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

A ring of ice with nine crystal teeth spins as it flies, face-on to the flight axis, shedding frost. `Hit()` breaks it into curved shards.

## Usage

Drop `Assets/FrostWheel.prefab` into a scene. It flies along `transform.forward`.

```csharp
effect.Play();
effect.SetDirection(aim, speed: 4f);
effect.Hit(contactPoint, contactNormal); // from your collision code
```

`Stop()` ends it without an impact. Tools > ConfusedGameDev > VFX > Rebuild Crystal-Toothed Ice Wheel Assets regenerates the
prefab and meshes.

## Parameters

| Field | Range | Default |
|---|---|---|
| `color` | | `#A9DFFF` |
| `size` | 0.25 to 2 | 1 |
| `speed` | 0.25 to 2 | 1 |
| `detail` | 0.25 to 2 | 1 |
| `density` | 0.125 to 1 | 0.5 |

Start-up takes 0.35s and the ending 0.8s of effect time.

## Layers

| Layer | Blend | Queue | Notes |
|---|---|---|---|
| Trail | alpha | Transparent+1 | Fixed-length broken ribbons |
| Body | alpha, ZWrite on | Transparent+2 | Torus and teeth with an ink edge |
| Particles | alpha | Transparent+3 | 512 quads, past-count quads collapse |
| Glow | additive | Transparent+4 | Contact flash, first 28% of an impact |
| Impact | alpha | Transparent+5 | Seven curved shards |

## Known differences from the web version

- Forward is +Z, not +X. Additive blending happens in linear space here. Compare with tonemapping and bloom off.
