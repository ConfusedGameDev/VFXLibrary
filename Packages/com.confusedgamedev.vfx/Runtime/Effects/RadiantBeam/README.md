# Solar Halo Beam

Port of **Solar Halo Beam** (`radiant-beam`, `kind 1`, `variant 4`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

A bright shaft with a soft sheath joins two turning seals of seven petals, with motes drifting off both. When it stops the seals drop away petal by petal.

## Usage

Drop `Assets/RadiantBeam.prefab` into a scene. It lies along `transform.forward`, centred on the transform.

```csharp
effect.Play();
effect.SetEndpoints(muzzle.position, target.position); // or effect.Length = 8f;
effect.Stop();
```

Call `SetEndpoints` again whenever an end moves. The length is the root's Z scale, so the end points stay
where they are through the start-up and the ending. Tools > ConfusedGameDev > VFX > Rebuild Solar Halo Beam Assets
regenerates the prefab and meshes.

## Parameters

| Field | Range | Default |
|---|---|---|
| `color` | | `#FFE3A0` |
| `size` | 0.25 to 2 | 1 |
| `speed` | 0.25 to 2 | 1 |
| `detail` | 0.25 to 2 | 1 |
| `density` | 0.125 to 1 | 0.5 |

`size` changes only the cross-section. `Length` is on the effect component and defaults to 4.8. Start-up takes
0.4s and the ending 0.6s of effect time.

## Layers

| Layer | Blend | Queue | Notes |
|---|---|---|---|
| Body | alpha | Transparent+2 | Shaft, sheath, rings and petals in one mesh |
| Particles | alpha | Transparent+3 | 512 quads around both seals, past-count quads collapse |

## Known differences from the web version

- Forward is +Z, not +X. Additive blending happens in linear space here. Compare with tonemapping and bloom off.
- Coincident end points leave a very short beam with its end details showing. The source hides the beam.
