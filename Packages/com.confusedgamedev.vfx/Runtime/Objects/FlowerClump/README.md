# Flower clump

Port of **Flower clump** (`flower-clump`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

Recolor petals, leaves and centers to vary a garden.

## Usage

Drop `FlowerClump.prefab` into a scene. The origin is the centre of the base, so it sits on the ground at Y 0. Units are meters.

Recolour it on the `VfxObject` component, or from code:

```csharp
GetComponent<VfxObject>().SetColors(primary, secondary, accent);
```

| Field | Default |
|---|---|
| `primary` | `#c896b4` |
| `secondary` | `#789579` |
| `accent` | `#dfc47e` |

924 triangles. Material: Object Vegetation, with wind and falling leaves in the shader. Plants use a fixed painted light, as on the site, so scene lights do not change them. They do cast shadows.
