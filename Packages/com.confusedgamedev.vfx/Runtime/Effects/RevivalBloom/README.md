# Vitality Blossom

Port of **Vitality Blossom** (`revival-bloom`, `kind 3`, `variant 9`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

Two rings of petals gather, rise and open into a flower while seeds of light climb out of its heart.

## Usage

Drop `Assets/RevivalBloom.prefab` into a scene. It is a one-shot: it plays once and finishes on its own after
2.2s of effect time, with no `Stop()` ending. Tools > ConfusedGameDev > VFX > Rebuild Vitality Blossom Assets
regenerates the prefab and meshes.

## Parameters

| Field | Range | Default |
|---|---|---|
| `color` | | `#FF8FBD` |
| `size` | 0.25 to 2 | 1 |
| `speed` | 0.25 to 2 | 1 |
| `detail` | 0.25 to 2 | 1 |
| `density` | 0.125 to 1 | 0.5 |
| `quantity` | 1 to 28 | 14 |

## Layers

| Layer | Blend | Queue | Notes |
|---|---|---|---|
| Body | alpha | Transparent+1 | Twenty-eight petals, shown by `quantity`, and five rising motes |
| Particles | alpha | Transparent+2 | 512 tetrahedra, past-count ones collapse |

## Known differences from the web version

- Blending happens in linear space here. Compare with tonemapping and bloom off.
