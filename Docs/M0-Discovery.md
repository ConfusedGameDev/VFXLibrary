# M0 Discovery

Findings from https://00gamedevs.com, checked 2026-11-01. Catalog `contentVersion`:
`ef7ce13c6faa4569d639793b3d88db9a7b93fb46a7eae1d890b5061a60fce4f3`.

## What changes in the PRD

| PRD says | Found | Consequence |
|---|---|---|
| Parameters were not visible (page renders in JS) | `/ai/catalog.v2.json` lists every parameter, range and default | Presets can come from the catalog, no scraping |
| Nine showcased effects | 60 effects plus 46 objects | M6 is larger than it looked |
| "Copied code" may be minified | Readable JS with real GLSL, about 7,400 lines per module, dense in places | Hand porting is viable |
| Commercial-use statement | Formal MIT license; notices must be preserved | Ports must carry the notices below |
| lil-gui-style control panels per effect | Most effects share the same five controls | They live on the `VfxPreset` base |
| Fireball, energy burst, magic barrier | All exist; ids below | Pilots confirmed |
| Unity version open | Unity 6.5 (6000.5.3f1), URP 17.5.0 | NFR-01 fixed |

## Pilot effects

| id | Site name | Category | Playback | Load | Stop lifecycle (`start` / `end`) | Bytes |
|---|---|---|---|---|---|---|
| `fireball` | Blazing Fireball | projectile | continuous | medium | 0.35 / 0.8 | 526,979 |
| `energy-burst` | Lightning Arc Burst | burst | one-shot | medium | 0.28 / 1.26 | 527,318 |
| `magic-barrier` | Runic Mesh Barrier | area | continuous | medium | 0.7 / 1 | 526,997 |

`lifecycle.start` and `lifecycle.end` are seconds of visual time, so `speed` scales them.

### Parameters

| Parameter | Range | Fireball | Energy burst | Magic barrier |
|---|---|---|---|---|
| `color` | `#RRGGBB` | `#ff823e` | `#2878ff` | `#bba3ff` |
| `size` | 0.25 to 2 | 1 | 1 | 1 |
| `speed` | 0.25 to 2 | 1 | 1 | 1 |
| `density` | 0.125 to 1 | 0.5 | 0.5 | 0.5 |
| `detail` | 0.25 to 2 | 1 | 1 | 1 |
| `quantity` | 1 to 24 | none | 12 | none |

The site's panel order, which FR-07 follows, is color, size, speed, detail, density; the catalog is
alphabetical. Checked on fireball only.

## The whole library

- Parameter use across the 60 effects: `color`, `size` and `detail` 59; `density` and `speed` 57;
  `quantity` 22; `spread` 5; the rest appear on one or two effects.
- Playback: 37 continuous, 22 one-shot, 1 triggered sequence.
- Integration: 59 `scene-object`, 1 `postprocess` (`impact-frame`, which will need a Renderer Feature).

## Source API to mirror

Factory `createVFX(options)` returns an asset with `group`, `update(deltaSeconds)`, `stop()`, `reset()`,
`dispose()`, `setOptions()` and a `finished` flag. Fireball also has `setDirection`. All three pilots
have `hit(worldPoint?, worldNormal?)`, which the PRD's `VfxEffect` API does not cover yet. `update` runs
until `finished`, which matches `VfxEffect.Tick` and `State`.

## Parity notes

- The site guide states scene VFX expect `SRGBColorSpace` and `NoToneMapping`. The parity scene should turn
  URP tonemapping off, or colours will drift for reasons unrelated to the port.
- The guide says downloads use original defaults, without the site's final tuning or automatic density
  reduction. The live page can differ from catalog defaults, so capture parity shots using explicit values.
- Modules depend on `three@0.187.0`, and the site validates on WebGL2.
- Fireball's module holds one shared runtime with `createEffect` branching on `kind` and `variant`, plus
  the spec. The other pilots are nearly the same size, so they likely do too. A port means reading
  only its own `kind`/`variant` branches, and `lifeVertex` and `lifeFragment` give its lifecycle.

## License

MIT, Copyright (c) 2026 00GameDevs (@00vchannel), statement recorded 2026-11-01. Three.js is separately MIT,
Copyright 2010-2026 three.js authors. Both notices ship in the package's `THIRD-PARTY-NOTICES.md`. The
license excludes the site's UI, branding, avatars and promotional images. Each module's header also
carries its notices.

## Out of scope for this pass

Module source has not been saved to the repo. Only fireball was inspected, in memory. The other two pilots
still need the same check before M3.
