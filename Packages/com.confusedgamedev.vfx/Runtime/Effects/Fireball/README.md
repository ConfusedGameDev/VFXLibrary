# Fireball

Port of **Blazing Fireball** (`fireball`, `kind 0`, `variant 0`) from https://00gamedevs.com, based on the
module published with catalog `contentVersion` `ef7ce13c...fce4f3`, inspected 2026-11-01. License: see
`THIRD-PARTY-NOTICES.md` at the package root.

## Usage

Drop `Assets/Fireball.prefab` into a scene. It flies along `transform.forward`.

```csharp
fireball.Play();
fireball.SetDirection(aim, speed: 4f);
fireball.Hit(contactPoint, contactNormal); // from your collision code
fireball.onFinished.AddListener(OnGone);
```

`Stop()` ends it without an impact. Tools > ConfusedGameDev > VFX > Rebuild Fireball Assets regenerates the
prefab and meshes.

## Parameters

In the site's panel order.

| Field | Site label | Range | Default |
|---|---|---|---|
| `color` | Main colour | | `#FF823E` |
| `size` | Projectile size (tail length unchanged) | 0.25 to 2 | 1 |
| `speed` | Flow speed | 0.25 to 2 | 1 |
| `detail` | Tail and glow strength | 0.25 to 2 | 1 |
| `density` | Particle density (384 of 768 at 0.5) | 0.125 to 1 | 0.5 |

Start-up takes 0.35s and the ending 0.8s of effect time, so `speed` scales both, while travel speed does not.

## Layers

| Layer | Blend | Queue | Notes |
|---|---|---|---|
| Core | alpha, ZWrite on | Transparent+2 | Alpha stays 1 while steady |
| Particles | additive | Transparent+3 | One quad per ember, past-count quads collapse in the vertex shader |
| Glow | additive | Transparent+4 | Contact flash, first 28% of an impact |
| Impact | alpha | Transparent+5 | 12 smoke-lit puffs |

## Known differences from the web version

- **Forward is +Z**, not +X. Shaders keep the source's axes and swap X and Z on output, which also converts
  the handedness. Compare against a Three.js camera at `(a, b, c)` with a Unity camera at `(c, b, a)`.
- **Additive blending happens in linear space** here, and in display space on the site, so embers can read
  slightly differently.
- **Compare with tonemapping and bloom off.** The site uses neither. Emissive values above 1 are not clamped
  in HDR, so bloom in a game will brighten this effect.
- The site's live preview may lower density automatically. It showed 0.15 during checking, while the
  catalog default this port uses is 0.5.
- Core and particle shapes follow the source math, but parity has only been checked by eye against the
  site's preview, at different camera angles.
- The core's plain `Stop()` ending shows faint vertical streaks in the blended stage. The site's scripted
  demo only shows the impact ending, so whether the original has them is unconfirmed.
