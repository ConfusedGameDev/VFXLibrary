# Spiraling Wind Spear

Port of **Spiraling Wind Spear** (`spiral-gale`, `kind 0`, `variant 6`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

Seven twisting ribbons of wind form a translucent spear with thin wind streaks behind it. `Hit()` unwinds eight spiralling ribbons forward.

## Usage

Drop `Assets/SpiralGale.prefab` into a scene. It flies along `transform.forward`.

```csharp
effect.Play();
effect.SetDirection(aim, speed: 4f);
effect.Hit(contactPoint, contactNormal); // from your collision code
```

`Stop()` ends it without an impact. Tools > ConfusedGameDev > VFX > Rebuild Spiraling Wind Spear Assets regenerates the
prefab and meshes.

## Parameters

| Field | Range | Default |
|---|---|---|
| `color` | | `#B4E5D5` |
| `size` | 0.25 to 2 | 1 |
| `speed` | 0.25 to 2 | 1 |
| `detail` | 0.25 to 2 | 1 |
| `density` | 0.125 to 1 | 0.5 |

Start-up takes 0.35s and the ending 0.8s of effect time.

## Layers

| Layer | Blend | Queue | Notes |
|---|---|---|---|
| Trail | alpha | Transparent+1 | Fixed-length broken ribbons |
| Body | alpha | Transparent+2 | Seven twisted tubes |
| Particles | alpha | Transparent+3 | 512 quads, past-count quads collapse |
| Glow | additive | Transparent+4 | Contact flash, first 28% of an impact |
| Impact | alpha | Transparent+5 | Eight ribbons shaped in the vertex shader |

## Known differences from the web version

- Forward is +Z, not +X. Additive blending happens in linear space here. Compare with tonemapping and bloom off.
