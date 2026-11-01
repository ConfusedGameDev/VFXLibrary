# Angular rock

Port of **Angular rock** (`angular-rock`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

Sharp edges and smaller stones fit slopes and caves.

## Usage

Drop `AngularRock.prefab` into a scene. The origin is the centre of the base, so it sits on the ground at Y 0. Units are meters.

Recolour it on the `VfxObject` component, or from code:

```csharp
GetComponent<VfxObject>().SetColors(primary, secondary, accent);
```

| Field | Default |
|---|---|
| `primary` | `#8d9da9` |
| `secondary` | `#b2b6a7` |
| `accent` | `#7d958c` |

1644 triangles. Material: Object Lit, with the watercolor paper pattern. It responds to scene lights.
