# Golden Chain Rain

Port of **Golden Chain Rain** (`golden-chain-rain`, `kind 2`, `variant 15`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

Three waves of gold chains fall from rippling golden pools in the air, each driving an arrowhead half into the ground. Glowing cracks branch from each landing and shed floating chips, then the chains dissolve from the top down into gold flakes.

## Usage

Drop `Assets/GoldenChainRain.prefab` into a scene. It is a one-shot: it plays once and finishes on its own after
4.8s of effect time, with no `Stop()` ending. Tools > ConfusedGameDev > VFX > Rebuild Golden Chain Rain Assets
regenerates the prefab and meshes.

## Parameters

| Field | Range | Default |
|---|---|---|
| `color` | | `#FFD166` |
| `size` | 0.25 to 2 | 1 |
| `speed` | 0.25 to 2 | 1 |
| `detail` | 0.25 to 2 | 1 |
| `density` | 0.125 to 1 | 0.5 |
| `quantity` | 1 to 12 | 8 |
| `spread` | 0.5 to 2 | 1 |
| `crackBloom` | 0 to 5 | 0.15 |
| `crackBloomSpread` | 0.25 to 3 | 1 |
| `textureDensity` | 0.25 to 3 | 0.7 |

## Layers

| Layer | Blend | Queue | Notes |
|---|---|---|---|
| CrackGlow | additive | Transparent+-1 | Soft light around the fissures |
| Cracks | alpha | Transparent | One branched pattern per landing |
| Body | opaque | Transparent | Geometry+1, 2592 sprite links, writes depth, the opaque texture is not needed |
| Arrowheads | opaque | Transparent | Geometry+1, half buried, cut at ground height |
| Ripples | opaque | Transparent | Geometry+2, the source pools |
| Halo | additive | Transparent+2 | Rim of the links |
| Feather | alpha | Transparent+2 | Soft edge of the pools |
| Bloom | additive | Transparent+3 | Broad glow of the pools |
| Motes | additive | Transparent+4 | Flakes eroded from chains and arrows |
| Chips | additive | Transparent+4 | Rise from the cracks, eight per allocated particle |

## Known differences from the web version

- Blending happens in linear space here. Compare with tonemapping and bloom off.
- Only the site's default sprite chains are ported. Its optional 3D tube links would need 450,000 vertices in the mesh this package bakes.
- The chain layout is worked out in the vertex shader, so `quantity` and `spread` need no mesh rebuild.
