# Magic Barrier

Runic Mesh Barrier, ported from [00gamedevs](https://00gamedevs.com) `magic-barrier` (MIT).

A hexagon-tiled dome rises from a rune circle on the ground, with small square glints across its surface. It loops until `Stop()`, then breaks outward in shards over one second.

| Parameter | Default | Range | Notes |
| --- | --- | --- | --- |
| `color` | `#bba3ff` | | |
| `size` | 1 | 0.2 to 2 | Dome radius is 1.85 at size 1. |
| `speed` | 1 | 0.1 to 3 | |
| `detail` | 1 | 0 to 2 | Overall opacity. |
| `density` | 0.5 | 0.1 to 1 | Share of the 768 glints in use. |

Layers, back to front: `Aura`, `Sigil`, `Shield`, `Particles`. The prefab's origin sits on the ground at the dome's centre.

Rebuild the baked assets with **Tools > ConfusedGameDev > VFX > Rebuild Magic Barrier Assets**.
