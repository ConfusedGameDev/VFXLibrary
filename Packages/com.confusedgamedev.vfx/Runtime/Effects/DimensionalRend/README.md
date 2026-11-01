# Rift-Shattering Slashes

Port of **Rift-Shattering Slashes** (`dimensional-rend`, `kind 3`, `variant 1`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

Slashes of light cross the view one after another, windows of shifted background open along them, and at the release slices of the scene burst outward and hang in the air as they fade.

## Usage

Drop `Assets/DimensionalRend.prefab` into a scene. It is a one-shot: it plays once and finishes on its own after
3.4s of effect time, with no `Stop()` ending. Tools > ConfusedGameDev > VFX > Rebuild Rift-Shattering Slashes Assets
regenerates the prefab and meshes.

## Parameters

| Field | Range | Default |
|---|---|---|
| `color` | | `#729DFF` |
| `size` | 0.25 to 2 | 1 |
| `speed` | 0.25 to 2 | 1 |
| `detail` | 0.25 to 2 | 1 |
| `density` | 0.125 to 1 | 0.5 |
| `cutSize` | 0.25 to 4 | 2 |
| `quantity` | 1 to 32 | 18 |
| `spread` | 0.5 to 4 | 2 |
| `panelCount` | 0 to 32 | 9 |

## Layers

| Layer | Blend | Queue | Notes |
|---|---|---|---|
| Cuts | alpha, samples the scene | Transparent | Up to 32 triangular windows, shown by `panelCount` |
| Glow | additive | Transparent+1 | A blade and a delayed trace per slash, shown by `quantity` |
| Shards | alpha, samples the scene | Transparent+2 | 128 slices, past-count ones collapse |
| Impact | alpha | Transparent+3 | The brief spark at the release |

## Known differences from the web version

- Blending happens in linear space here. Compare with tonemapping and bloom off.
- The inherited `size` is ignored: `cutSize` replaces it, because the site's range goes past the base slider. `density` defaults to 0.3 and only sets the shards.
- **Requires the Opaque Texture.** Cuts and Shards sample `_CameraOpaqueTexture` where the site samples three.js's transmission capture. Enable Opaque Texture on the URP asset or on the camera. Without it they show black. Transparent objects are not in that texture, so they will not appear in the slices.
- On the site the blade glow is drawn into the capture, so it shows displaced through the windows. URP cannot put an additive layer into the opaque texture, so here Glow draws over the windows, undisplaced.
