# Forked Lightning Stream

Port of **Forked Lightning Stream** (`arc-ray`, `kind 1`, `variant 3`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

Jagged arcs with short forks join the two ends, redrawn 18 times a second, while small coronas crackle around both ends and needles of light leave them. `quantity` sets how many arcs run.

## Usage

Drop `Assets/ArcRay.prefab` into a scene. It lies along `transform.forward`, centred on the transform.

```csharp
effect.Play();
effect.SetEndpoints(muzzle.position, target.position); // or effect.Length = 8f;
effect.Stop();
```

Call `SetEndpoints` again whenever an end moves. The length is the root's Z scale, so the end points stay
where they are through the start-up and the ending. Tools > ConfusedGameDev > VFX > Rebuild Forked Lightning Stream Assets
regenerates the prefab and meshes.

## Parameters

| Field | Range | Default |
|---|---|---|
| `color` | | `#2878FF` |
| `size` | 0.25 to 2 | 1 |
| `speed` | 0.25 to 2 | 1 |
| `detail` | 0.25 to 2 | 1 |
| `density` | 0.125 to 1 | 0.5 |
| `quantity` | 1 to 12 | 6 |

`size` changes only the cross-section. `Length` is on the effect component and defaults to 4.8. Start-up takes
0.4s and the ending 0.6s of effect time.

## Layers

| Layer | Blend | Queue | Notes |
|---|---|---|---|
| Corona | alpha | Transparent+2 | Nine short arcs around each end |
| Lightning | alpha | Transparent+3 | 12 arcs with three forks each, past-quantity arcs fade out |
| Particles | additive | Transparent+3 | 768 quads, past-count quads collapse |
| Flares | additive | Transparent+4 | Billboards at each end |

## Known differences from the web version

- Forward is +Z, not +X. Additive blending happens in linear space here. Compare with tonemapping and bloom off.
- Coincident end points leave a very short beam with its end details showing. The source hides the beam.
