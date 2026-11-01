# White-Hot Fireburst

Port of **White-Hot Fireburst** (`fire-explosion`, `kind 3`, `variant 0`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

A rolling fireball bursts, its hot folds burn through to soot, and it leaves a cracked scorch, torn pressure bands, smoke trails and sparks. All the shapes are generated; nothing is a texture.

## Usage

Drop `Assets/FireExplosion.prefab` into a scene. It is a one-shot: it plays once and finishes on its own after
2.8s of effect time, with no `Stop()` ending. Tools > ConfusedGameDev > VFX > Rebuild White-Hot Fireburst Assets
regenerates the prefab and meshes.

## Parameters

| Field | Range | Default |
|---|---|---|
| `color` | | `#FF5C26` |
| `size` | 0.25 to 2 | 1 |
| `speed` | 0.25 to 2 | 1 |
| `detail` | 0.25 to 2 | 1 |
| `density` | 0.125 to 1 | 0.5 |

## Layers

| Layer | Blend | Queue | Notes |
|---|---|---|---|
| Volume | opaque | Transparent | Eighteen wrinkled lobes eroded by 3D noise, in the Geometry queue with depth writes |
| Ground | alpha | Transparent+2 | Scorch, smoke rings and torn pressure bands |
| Trails | alpha | Transparent+2 | Eleven ballistic tubes |
| Halo | additive | Transparent+3 | A soft glow per lobe and one wide spill |
| Embers | additive | Transparent+3 | 256 quads, past-count quads collapse |

## Known differences from the web version

- Blending happens in linear space here. Compare with tonemapping and bloom off.
