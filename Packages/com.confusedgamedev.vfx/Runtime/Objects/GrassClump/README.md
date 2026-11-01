# Grass clump

Port of **Grass clump** (`grass-clump`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

Leaves of different heights fill small spaces beside paths.

## Usage

Drop `GrassClump.prefab` into a scene. The origin is the centre of the base, so it sits on the ground at Y 0. Units are meters.

Recolour it on the `VfxObject` component, or from code:

```csharp
GetComponent<VfxObject>().SetColors(primary, secondary, accent);
```

| Field | Default |
|---|---|
| `primary` | `#8fa66c` |
| `secondary` | `#637e67` |
| `accent` | `#c6ba79` |

870 triangles. Material: Object Vegetation, with wind and falling leaves in the shader. Plants use a fixed painted light, as on the site, so scene lights do not change them. They do cast shadows.
