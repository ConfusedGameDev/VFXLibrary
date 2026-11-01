# Wooden crate

Port of **Wooden crate** (`wooden-crate`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

Diagonal braces hold the crate together for warehouse scenes.

## Usage

Drop `WoodenCrate.prefab` into a scene. The origin is the centre of the base, so it sits on the ground at Y 0. Units are meters.

Recolour it on the `VfxObject` component, or from code:

```csharp
GetComponent<VfxObject>().SetColors(primary, secondary, accent);
```

| Field | Default |
|---|---|
| `primary` | `#b39a76` |
| `secondary` | `#8d785f` |
| `accent` | `#c7ae89` |

5920 triangles. Material: Object Lit, with the watercolor paper pattern. It responds to scene lights.
