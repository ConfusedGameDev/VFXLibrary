# Red Sector Spell Indicator

Port of **Red Sector Spell Indicator** (`spell-indicator-sector`, `kind 2`, `variant 17`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

A sector on the ground, with its apex at the object's origin, opening around its forward axis. It fills from the center to warn of a coming attack, flashes its edge once for 0.06s, and fades in 0.09s. It only draws: it triggers no damage or collisions, and finishing means invisible, not that the attack lands. Keep attack timing in the game.

## Usage

Drop `Assets/SpellIndicatorSector.prefab` into a scene, on an unscaled parent, and orient it to a flat or tilted plane. It does not fit uneven terrain. In `Auto` it fills over `warningDuration`. In `Manual`, call `SetProgress(0 to 1)`. `Stop()` cancels with a 0.12s fade and no flash. `Play()` restarts it. Tools > ConfusedGameDev > VFX > Rebuild Red Sector Spell Indicator Assets regenerates the prefab and mesh.

## Parameters

| Field | Range | Default |
|---|---|---|
| `color` | | `#FF303E` |
| `radius` | 0.25 to 20 | 3 |
| `detail` | 0.25 to 2, flow bands only | 1 |
| `warningDuration` | 0.1 to 30 | 2 |
| `progressMode` | `Auto`, `Manual` | `Auto` |
| `angleDegrees` | 5 to 360 | 90 |

`radius` replaces `size`, which does nothing here, like `density`. Leave `speed` at 1: the fill ignores it, as on the site, but the base class still scales the 0.12s cancel fade by it.

## Layers

| Layer | Blend | Queue | Notes |
|---|---|---|---|
| Surface | alpha | Transparent | One quad, the shape is a fragment mask |

## Known differences from the web version

- Blending happens in linear space here. Compare with tonemapping and bloom off.
