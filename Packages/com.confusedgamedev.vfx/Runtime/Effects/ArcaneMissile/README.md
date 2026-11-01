# Runic Crystal Missiles

Port of **Runic Crystal Missiles** (`arcane-missile`, `kind 0`, `variant 3`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

Crystal gems orbit the flight axis while flying forward, each leaving a spiral ribbon of rune packets and small diamond glints. `Hit()` scatters runes and crystals.

## Usage

Drop `Assets/ArcaneMissile.prefab` into a scene. It flies along `transform.forward`.

```csharp
effect.Play();
effect.SetDirection(aim, speed: 4f);
effect.Hit(contactPoint, contactNormal); // from your collision code
```

`Stop()` ends it without an impact. Tools > ConfusedGameDev > VFX > Rebuild Runic Crystal Missiles Assets regenerates the
prefab and meshes.

## Parameters

| Field | Range | Default |
|---|---|---|
| `color` | | `#C99AFF` |
| `size` | 0.25 to 2 | 1 |
| `speed` | 0.25 to 2 | 1 |
| `detail` | 0.25 to 2 | 1 |
| `density` | 0.125 to 1 | 0.5 |
| `quantity` (`ArcaneMissilePreset`) | 1 to 6 | 3 |
| `spread` (`ArcaneMissilePreset`) | 0.5 to 3 | 1 |

Start-up takes 0.35s and the ending 0.8s of effect time.

## Layers

| Layer | Blend | Queue | Notes |
|---|---|---|---|
| Trails | alpha | Transparent+2 | Six 64-step ribbons, those past `quantity` are discarded |
| Gems | alpha | Transparent+3 | Six octahedra, those past `quantity` are discarded |
| Particles | additive | Transparent+3 | 768 quads, past-count quads collapse |
| Glow | additive | Transparent+4 | Contact flash, first 28% of an impact |
| Impact | alpha | Transparent+5 | Seven rune and crystal groups |

## Known differences from the web version

- Forward is +Z, not +X. Additive blending happens in linear space here. Compare with tonemapping and bloom off.
