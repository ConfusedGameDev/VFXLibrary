# Pine tree

Port of **Pine tree** (`pine-tree`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

Spreading branches carry needle sprays. Look closer for little twigs, bark grooves and pale new growth.

## Usage

Drop `PineTree.prefab` into a scene. The origin is the centre of the base, so it sits on the ground at Y 0. Units are meters.

Recolour it on the `VfxObject` component, or from code:

```csharp
GetComponent<VfxObject>().SetColors(primary, secondary, accent);
```

| Field | Default |
|---|---|
| `primary` | `#477c59` |
| `secondary` | `#806044` |
| `accent` | `#b5b766` |

11486 triangles. Material: Object Vegetation, with wind and falling leaves in the shader. Plants use a fixed painted light, as on the site, so scene lights do not change them. They do cast shadows.
