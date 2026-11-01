# Round canopy tree

Port of **Round canopy tree** (`round-tree`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

A curved trunk splits into branches under golden leaves with veins and notched edges, like a painting moving in the breeze.

## Usage

Drop `RoundTree.prefab` into a scene. The origin is the centre of the base, so it sits on the ground at Y 0. Units are meters.

Recolour it on the `VfxObject` component, or from code:

```csharp
GetComponent<VfxObject>().SetColors(primary, secondary, accent);
```

| Field | Default |
|---|---|
| `primary` | `#e3952e` |
| `secondary` | `#795235` |
| `accent` | `#f5ce67` |

8028 triangles. Material: Object Vegetation, with wind and falling leaves in the shader. Plants use a fixed painted light, as on the site, so scene lights do not change them. They do cast shadows.
