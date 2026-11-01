# Impact Frame

Port of **Impact Frame** (`impact-frame`, a post-process) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

A 400 ms comic impact over the whole camera image: seven black and white beats of ink strokes, brush stars and a monochrome blast at the point of contact. It adds no game freeze, collision logic or camera work.

## Setup

This is not a prefab. It needs a URP Renderer Feature, which the package cannot add to your renderer for you.

1. Select your Universal Renderer Data asset. Check each one in use, per quality level.
2. In its Inspector: Add Renderer Feature > Impact Frame.
3. Check that the feature's Shader field holds `ConfusedGameDev/Vfx/ImpactFrame`, so builds include it.
4. Add an `ImpactFrameTrigger` component to any object.

## Usage

```csharp
Vector3 viewport = camera.WorldToViewportPoint(hitPoint);
trigger.Fire(viewport, attackDirection);
```

`Fire` takes a viewport center with a bottom-left origin, and returns false while a sequence runs: triggers are not queued. `SetCenter` tracks a moving hit without restarting. `Cancel` stops at once. Without a direction, strokes run radially. The first star of a pose attracts the ink, and the direction is the fallback when stars are off.

For solid silhouettes, list the character and weapon in `subjects`. They draw in a mask, tested against the camera's depth, so whatever occludes them stays in front. Their materials are ignored: alpha cutouts and vertex displacement need a `subjectMask` texture instead, whose red channel holds visible coverage for this camera and viewport.

## Parameters

| Field | Range | Default |
|---|---|---|
| `threshold` | 0 to 1 | 0.5 |
| `softness` | 0 to 1 | 0.05 |
| `strokeLength` | 0 to 1 | 0.65 |
| `inkDensity` | 0 to 1 | 0.65 |
| `backgroundSuppression` | 0 to 1 | 0.9 |
| `starSize` | 0.25 to 2 | 1 |
| `starStrength` | 0 to 1 | 1 |
| `sequence` | stages of pose, mode, `durationMs`, `intensity` | the seven beats |

## Rendering

`ImpactFrameFeature` injects before post-processing by default. It records two Render Graph raster passes only while a stage is showing: the subject mask, when there are `subjects`, then one fullscreen pass that becomes the new camera color. It asks for an intermediate texture, so on the frames it runs the camera cannot render straight to the back buffer. Place it before screen-warping effects, or warp the mask to match. It covers anything rendered into the camera image, so draw the HUD on an overlay camera or canvas.

## Known differences from the web version

- `setSubjects` here takes Renderers, and tests them against depth rather than redrawing the scene in black. Transparent objects in front of a subject do not cover it, and neither does anything that writes no depth.
- `subjectMask` as a plain texture is untested in single-pass XR, where the shader expects a texture array.
