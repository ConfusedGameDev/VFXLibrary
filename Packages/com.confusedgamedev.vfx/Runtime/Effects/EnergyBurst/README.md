# Energy Burst

Lightning Arc Burst, ported from [00gamedevs](https://00gamedevs.com) `energy-burst` (MIT).

Forked lightning leaps out of a ground contact point, over a shockwave ring, a low cloud and hot sparks. It is a one-shot: `Stop()` is not needed, and `onFinished` fires at 2.8 seconds.

| Parameter | Default | Range | Notes |
| --- | --- | --- | --- |
| `color` | `#2878ff` | | |
| `size` | 1 | 0.2 to 2 | |
| `speed` | 1 | 0.1 to 3 | |
| `detail` | 1 | 0 to 2 | Spark, fragment and cloud opacity. |
| `density` | 1 | 0.1 to 1 | Share of the 768 particles in use. |
| `quantity` | 12 | 1 to 24 | Main arcs. Each has two forks. |

Layers, back to front: `Clouds`, `Wave`, `Arcs`, `Fragments`, `Sparks`, `Flash`. The contact point is 1.2 units below the prefab's origin at size 1, as on the site.

Rebuild the baked assets with **Tools > ConfusedGameDev > VFX > Rebuild Energy Burst Assets**.
