# Threadwoven Beam

Port of **Threadwoven Beam** (`continuous-beam`, `kind 1`, `variant 0`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

A thin ray runs between two fixed points with bright filaments winding around it. The source end shows a ring aperture and the target end throws sparks.

## Usage

Drop `Assets/ContinuousBeam.prefab` into a scene. It lies along `transform.forward`, centred on the transform.

```csharp
effect.Play();
effect.SetEndpoints(muzzle.position, target.position); // or effect.Length = 8f;
effect.Stop();
```

Call `SetEndpoints` again whenever an end moves. The length is the root's Z scale, so the end points stay
where they are through the start-up and the ending. Tools > ConfusedGameDev > VFX > Rebuild Threadwoven Beam Assets
regenerates the prefab and meshes.

## Parameters

| Field | Range | Default |
|---|---|---|
| `color` | | `#FF6555` |
| `size` | 0.25 to 2 | 1 |
| `speed` | 0.25 to 2 | 1 |
| `detail` | 0.25 to 2 | 1 |
| `density` | 0.125 to 1 | 0.5 |

`size` changes only the cross-section. `Length` is on the effect component and defaults to 4.8. Start-up takes
0.4s and the ending 0.6s of effect time.

## Layers

| Layer | Blend | Queue | Notes |
|---|---|---|---|
| Sheath | additive | Transparent+1 | Wide tube with slow filaments |
| Body | additive | Transparent+2 | Core tube with fast filaments |
| Discs | additive | Transparent+2 | Rings facing along the beam at each end |
| Particles | additive | Transparent+3 | 512 quads, past-count quads collapse |
| Flares | additive | Transparent+4 | Billboards at each end |

## Known differences from the web version

- Forward is +Z, not +X. Additive blending happens in linear space here. Compare with tonemapping and bloom off.
- Coincident end points leave a very short beam with its end details showing. The source hides the beam.
