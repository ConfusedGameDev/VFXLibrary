# Charged Light Cannon

Port of **Charged Light Cannon** (`charged-beam`, `kind 1`, `variant 2`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

Light spirals into the source for about 1.5 seconds, then a lance of five blades shoots across and keeps firing, with shock rings at the target. It charges only once; `Play()` charges again.

## Usage

Drop `Assets/ChargedBeam.prefab` into a scene. It lies along `transform.forward`, centred on the transform.

```csharp
effect.Play();
effect.SetEndpoints(muzzle.position, target.position); // or effect.Length = 8f;
effect.Stop();
```

Or move the prefab's `EmitterA` and `EmitterB` children, or assign any scene transforms to the effect's Emitter A and Emitter B, and the beam follows them every frame. While you drag an emitter with the move tool, the beam waits and catches up when you let go. Turn on Detect Hits to end it on the first non-trigger collider in Hit Layers, so it stops at anything between the two. Clear either emitter to go back to `SetEndpoints`.

Call `SetEndpoints` again whenever an end moves. The length is the root's Z scale, so the end points stay
where they are through the start-up and the ending. Tools > ConfusedGameDev > VFX > Rebuild Charged Light Cannon Assets
regenerates the prefab and meshes.

## Parameters

| Field | Range | Default |
|---|---|---|
| `color` | | `#F6C76C` |
| `size` | 0.25 to 2 | 1 |
| `speed` | 0.25 to 2 | 1 |
| `detail` | 0.25 to 2 | 1 |
| `density` | 0.125 to 1 | 0.5 |

`size` changes only the cross-section. `Length` is on the effect component and defaults to 4.8. Start-up takes
1.6s and the ending 0.6s of effect time.

## Layers

| Layer | Blend | Queue | Notes |
|---|---|---|---|
| Discs | additive | Transparent+2 | Iris at the source, shock rings at the target |
| Lance | additive | Transparent+3 | Five strips, the first is the thin guide line |
| Particles | additive | Transparent+3 | 768 quads shared with the streams |
| Charge | additive | Transparent+3 | Up to 7 spiral streams, 1.6% of the density pool |
| Flares | additive | Transparent+4 | Billboards at each end |

## Known differences from the web version

- Forward is +Z, not +X. Additive blending happens in linear space here. Compare with tonemapping and bloom off.
- Coincident end points leave a very short beam with its end details showing. The source hides the beam.
