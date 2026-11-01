# Rising Steam Jet

Port of **Rising Steam Jet** (`steam-jet`, `kind 5`, `variant 2`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

A narrow jet of steam shoots upward and breaks into mist at the top.

## Usage

Drop `Assets/SteamJet.prefab` into a scene. Its origin sits 1.4 units above the ground plane, as on the site. It runs until `Stop()`, then plays its ending. Tools > ConfusedGameDev > VFX > Rebuild Rising Steam Jet Assets regenerates the prefab and meshes.

## Parameters

| Field | Range | Default |
|---|---|---|
| `color` | | `#D1DFE8` |
| `size` | 0.25 to 2 | 1 |
| `speed` | 0.25 to 2 | 1 |
| `detail` | 0.25 to 2 | 1 |
| `density` | 0.125 to 1 | 0.5 |

Start-up takes 0.5s and the ending 1.2s of effect time.

## Layers

| Layer | Blend | Queue | Notes |
|---|---|---|---|
| Clouds | alpha | Transparent | 96 lit billboards, 48 by default, past-count quads collapse |

## Known differences from the web version

- Blending happens in linear space here. Compare with tonemapping and bloom off.
