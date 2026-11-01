# Corrosive Venom Jet

Port of **Corrosive Venom Jet** (`venom-stream`, `kind 1`, `variant 6`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

Teardrop slugs of venom race from the source to the target and splash there in tongues and falling drops. After `Stop()` no slugs are born and the ones in flight finish. `quantity` sets the slugs per cycle.

## Usage

Drop `Assets/VenomStream.prefab` into a scene. It lies along `transform.forward`, centred on the transform.

```csharp
effect.Play();
effect.SetEndpoints(muzzle.position, target.position); // or effect.Length = 8f;
effect.Stop();
```

Call `SetEndpoints` again whenever an end moves. The length is the root's Z scale, so the end points stay
where they are through the start-up and the ending. Tools > ConfusedGameDev > VFX > Rebuild Corrosive Venom Jet Assets
regenerates the prefab and meshes.

## Parameters

| Field | Range | Default |
|---|---|---|
| `color` | | `#ACDC6F` |
| `size` | 0.25 to 2 | 1 |
| `speed` | 0.25 to 2 | 1 |
| `detail` | 0.25 to 2 | 1 |
| `density` | 0.125 to 1 | 0.5 |
| `quantity` | 1 to 16 | 8 |

`size` changes only the cross-section. `Length` is on the effect component and defaults to 4.8. Start-up takes
0.25s and the ending 0.7s of effect time.

## Layers

| Layer | Blend | Queue | Notes |
|---|---|---|---|
| Body | alpha | Transparent+1 | Slugs, droplets, splash tongues and drops in one mesh. The lifecycle runs in its vertex shader |
| Droplets | alpha | Transparent+2 | 512 tetrahedra, past-count ones collapse |

## Known differences from the web version

- Forward is +Z, not +X. Additive blending happens in linear space here. Compare with tonemapping and bloom off.
- Coincident end points leave a very short beam with its end details showing. The source hides the beam.
