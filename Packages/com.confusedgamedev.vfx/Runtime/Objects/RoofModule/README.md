# Roof module

Port of **Roof module** (`roof-module`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

Two tiled slopes can be placed on your own house.

## Usage

Drop `RoofModule.prefab` into a scene. The origin is the centre of the base, so it sits on the ground at Y 0. Units are meters.

Recolour it on the `VfxObject` component, or from code:

```csharp
GetComponent<VfxObject>().SetColors(primary, secondary, accent);
```

| Field | Default |
|---|---|
| `primary` | `#b47d70` |
| `secondary` | `#8f7764` |
| `accent` | `#c49f83` |

7816 triangles. Material: Object Lit, with the watercolor paper pattern. It responds to scene lights.
