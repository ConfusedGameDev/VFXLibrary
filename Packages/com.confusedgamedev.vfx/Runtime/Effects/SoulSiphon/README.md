# Dark Energy Siphon

Port of **Dark Energy Siphon** (`soul-siphon`, `kind 1`, `variant 5`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

Orbs of dark energy with trailing cones stream from the target back to the source along three twisting strands, between two rings of arc segments. After `Stop()` no orbs are born and the ones in flight finish their way home. `quantity` sets the orbs per cycle.

## Usage

Drop `Assets/SoulSiphon.prefab` into a scene. It lies along `transform.forward`, centred on the transform.

```csharp
effect.Play();
effect.SetEndpoints(muzzle.position, target.position); // or effect.Length = 8f;
effect.Stop();
```

Pass the caster as the start and the target as the end. The stream flows from the end back to the start.

Call `SetEndpoints` again whenever an end moves. The length is the root's Z scale, so the end points stay
where they are through the start-up and the ending. Tools > ConfusedGameDev > VFX > Rebuild Dark Energy Siphon Assets
regenerates the prefab and meshes.

## Parameters

| Field | Range | Default |
|---|---|---|
| `color` | | `#A883E8` |
| `size` | 0.25 to 2 | 1 |
| `speed` | 0.25 to 2 | 1 |
| `detail` | 0.25 to 2 | 1 |
| `density` | 0.125 to 1 | 0.5 |
| `quantity` | 1 to 18 | 9 |

`size` changes only the cross-section. `Length` is on the effect component and defaults to 4.8. Start-up takes
0.35s and the ending 0.65s of effect time.

## Layers

| Layer | Blend | Queue | Notes |
|---|---|---|---|
| Body | alpha | Transparent+1 | Strands, orbs, tails and end arcs in one mesh. The lifecycle runs in its vertex shader |
| Droplets | alpha | Transparent+2 | 512 tetrahedra, past-count ones collapse |

## Known differences from the web version

- Forward is +Z, not +X. Additive blending happens in linear space here. Compare with tonemapping and bloom off.
- Coincident end points leave a very short beam with its end details showing. The source hides the beam.
