# Luminous Vortex Black Hole

Port of **Luminous Vortex Black Hole** (`black-hole`, `kind 2`, `variant 9`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

A black horizon with a burning halo hangs in the air, ringed by a painted accretion disk. Light streaks arc over it and spiral in, and everything behind it bends. The hole sits at 1.5 times `holeSize` above the origin, so the defaults make something 36 units wide with its centre 9 units up.

## Usage

Drop `Assets/BlackHole.prefab` into a scene. It opens over 1.1s and runs until `Stop()`, then closes over
1.4s of effect time. Tools > ConfusedGameDev > VFX > Rebuild Luminous Vortex Black Hole Assets regenerates the prefab and meshes.

## Parameters

| Field | Range | Default |
|---|---|---|
| `color` | | `#FFAB42` |
| `size` | 0.25 to 2 | 1 |
| `speed` | 0.25 to 2 | 1 |
| `detail` | 0.25 to 2 | 1 |
| `density` | 0.125 to 1 | 0.5 |
| `holeSize` | 0.25 to 12 | 6 |
| `holeDetail` | 0.25 to 4 | 2 |

## Layers

| Layer | Blend | Queue | Notes |
|---|---|---|---|
| RearDisk | premultiplied | Transparent | The half of the disk behind the hole |
| OuterLens | alpha, samples the scene | Transparent+1 | A flat volume of refraction around the disk |
| Lens | alpha, samples the scene | Transparent+2 | The horizon, its halo and the strong bend |
| FrontDisk | premultiplied | Transparent+3 | The half of the disk in front of the hole |
| Infall | additive | Transparent+4 | 256 streaks, past-count ones collapse |

## Known differences from the web version

- Blending happens in linear space here. Compare with tonemapping and bloom off.
- The inherited `size` and `detail` are ignored: `holeSize` and `holeDetail` replace them, because the site's ranges go past the base sliders. `density` defaults to 1.
- **Requires the Opaque Texture.** Both lenses sample `_CameraOpaqueTexture` where the site samples three.js's transmission capture. Enable Opaque Texture on the URP asset or on the camera. Without it the lenses show black. Transparent objects are not in that texture, so they will not bend.
- On the site the rear disk is drawn into the capture, so the lens bends it into the arch over the hole. URP cannot put this premultiplied layer into the opaque texture, so each lens traces its bent ray to the disk's plane and shades the disk there. It renders as one flat sheet with no thickness, and it adds a second run of the brush strokes per lens pixel. This is the heaviest effect in the package, so test it on your target hardware.
