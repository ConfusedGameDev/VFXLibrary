# Gate of Astral Tracery

Port of **Gate of Astral Tracery** (`astral-gate`, `kind 8`, `variant 0`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

A ring of sixteen glowing frame sections unfolds into an oval gate over a dark membrane of swirling light and stars. The gate faces +Z and its base sits near the origin.

## Usage

Drop `Assets/AstralGate.prefab` into a scene. It opens over 0.8s and runs until `Stop()`, then closes over
0.8s of effect time. Tools > ConfusedGameDev > VFX > Rebuild Gate of Astral Tracery Assets regenerates the prefab and meshes.

## Parameters

| Field | Range | Default |
|---|---|---|
| `color` | | `#C1B8FF` |
| `size` | 0.25 to 2 | 1 |
| `speed` | 0.25 to 2 | 1 |
| `detail` | 0.25 to 2 | 1 |
| `density` | 0.125 to 1 | 0.5 |

## Layers

| Layer | Blend | Queue | Notes |
|---|---|---|---|
| Frame | alpha | Transparent+1 | Sixteen sections, each with a bright inset |
| Membrane | alpha | Transparent+2 | The starfield disc |
| Particles | alpha | Transparent+3 | 512 tetrahedra, past-count ones collapse |

## Known differences from the web version

- Blending happens in linear space here. Compare with tonemapping and bloom off.
