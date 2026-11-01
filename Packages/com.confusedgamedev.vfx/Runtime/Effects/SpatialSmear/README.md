# Riftblade Trail

Port of **Riftblade Trail** (`spatial-smear`, `kind 2`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

A swung blade leaves a clear ribbon that bends the scene behind it into fine bands, with a faint rim and a thin bright edge. Each part fades within 0.18s, so a slow blade leaves almost nothing.

## Usage

This effect draws nothing until it has a weapon. It records the blade, with no sword, input or animation of its own.

```csharp
effect.AttachWeapon(sword, Vector3.zero, Vector3.up * 1.2f); // base and tip, in the sword's local space
effect.Play();
```

Or set Weapon, Blade Base and Blade Tip in the inspector. Drop `Assets/SpatialSmear.prefab` into a scene, and keep it apart from the weapon's hierarchy: the ribbon is world-space history, stored relative to the prefab. It samples in `LateUpdate`, after animators. `Stop()` or `DetachWeapon()` ends sampling and the ribbon runs out over 0.18s of effect time. Tools > ConfusedGameDev > VFX > Rebuild Riftblade Trail Assets regenerates the prefab.

## Parameters

| Field | Range | Default |
|---|---|---|
| `color` | | `#E9F5FF` |
| `size` | 0.25 to 1 | 1 |
| `speed` | 0.25 to 2 | 1 |
| `detail` | 0.25 to 2 | 1 |
| `density` | 0.125 to 1 | 0.5 |

`size` is the share of the blade the ribbon covers, measured from the tip. The inspector's slider goes to 2, but values above 1 act as 1. `density` sets how many fine lines show.

## Layers

| Layer | Blend | Queue | Notes |
|---|---|---|---|
| Refraction | alpha, samples the scene | Transparent+1 | The clear face of the ribbon |
| Halo | additive | Transparent+2 | A faint rim and `density` fine lines |
| Edge | additive | Transparent+3 | The bright line the tip traces |

All layers share one dynamic mesh, created on `Play()`. Its 64 positions and index range update every frame without allocating.

## Known differences from the web version

- Blending happens in linear space here. Compare with tonemapping and bloom off.
- The site's preview sword, pointer control and auto demo are not part of its module, so they are not ported.
- **Requires the Opaque Texture.** Refraction samples `_CameraOpaqueTexture` where the site samples three.js's transmission capture. Enable Opaque Texture on the URP asset or on the camera. Without it the ribbon shows black. Transparent objects are not in that texture, so they will not bend.
