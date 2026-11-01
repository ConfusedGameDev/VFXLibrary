# Gleaming Blade Trail

Port of **Gleaming Blade Trail** (`weapon-smear`, `kind 2`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

A swung blade leaves a clear blue ribbon with fine lines along it, a soft glow near the tip and a bright cutting edge. Each part fades within 0.18s, so a slow blade leaves almost nothing.

## Usage

This effect draws nothing until it has a weapon. It records the blade, with no sword, input or animation of its own.

```csharp
effect.AttachWeapon(sword, Vector3.zero, Vector3.up * 1.2f); // base and tip, in the sword's local space
effect.Play();
```

Or set Weapon, Blade Base and Blade Tip in the inspector. Drop `Assets/WeaponSmear.prefab` into a scene, and keep it apart from the weapon's hierarchy: the ribbon is world-space history, stored relative to the prefab. It samples in `LateUpdate`, after animators. `Stop()` or `DetachWeapon()` ends sampling and the ribbon runs out over 0.18s of effect time. Tools > ConfusedGameDev > VFX > Rebuild Gleaming Blade Trail Assets regenerates the prefab.

## Parameters

| Field | Range | Default |
|---|---|---|
| `color` | | `#2878FF` |
| `size` | 0.25 to 1 | 1 |
| `speed` | 0.25 to 2 | 1 |
| `detail` | 0.25 to 2 | 1 |
| `density` | 0.125 to 1 | 0.5 |

`size` is the share of the blade the ribbon covers, measured from the tip. The inspector's slider goes to 2, but values above 1 act as 1. `density` sets how many fine lines show.

## Layers

| Layer | Blend | Queue | Notes |
|---|---|---|---|
| Blade | alpha | Transparent+1 | The face of the ribbon, with `density` fine lines |
| Halo | additive | Transparent+2 | Soft light near the tip |
| Edge | additive | Transparent+3 | The bright line the tip traces |

All layers share one dynamic mesh, created on `Play()`. Its 64 positions and index range update every frame without allocating.

## Known differences from the web version

- Blending happens in linear space here. Compare with tonemapping and bloom off.
- The site's preview sword, pointer control and auto demo are not part of its module, so they are not ported.
