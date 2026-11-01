# Hooked Binding Sigil

Port of **Hooked Binding Sigil** (`binding-curse`, `kind 2`, `variant 5`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

Curved hooked bands rise from a three-armed sigil and tighten in turn around whatever stands at its centre. In its ending they loosen, droop and rot away.

## Usage

Drop `Assets/BindingCurse.prefab` into a scene with its origin on the ground. It runs until `Stop()`, then plays its
one-second ending. Tools > ConfusedGameDev > VFX > Rebuild Hooked Binding Sigil Assets regenerates the prefab and meshes.

## Parameters

| Field | Range | Default |
|---|---|---|
| `color` | | `#AE7BE5` |
| `size` | 0.25 to 2 | 1 |
| `speed` | 0.25 to 2 | 1 |
| `detail` | 0.25 to 2 | 1 |
| `density` | 0.125 to 1 | 0.5 |
| `quantity` | 1 to 6 | 3 |

Start-up takes 0.7s and the ending 1s of effect time.

## Layers

| Layer | Blend | Queue | Notes |
|---|---|---|---|
| Sigil | alpha | Transparent | Procedural emblem |
| Body | alpha, ZWrite on | Transparent+2 | Bands with an ink edge, running their own ending |
| Particles | alpha | Transparent+3 | 512 quads, past-count quads collapse |

## Known differences from the web version

- Blending happens in linear space here. Compare with tonemapping and bloom off.
