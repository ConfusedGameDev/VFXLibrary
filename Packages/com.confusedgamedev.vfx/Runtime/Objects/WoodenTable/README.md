# Wooden table

Port of **Wooden table** (`wooden-table`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

A plank top can hold props or form part of a market stall.

## Usage

Drop `WoodenTable.prefab` into a scene. The origin is the centre of the base, so it sits on the ground at Y 0. Units are meters.

Recolour it on the `VfxObject` component, or from code:

```csharp
GetComponent<VfxObject>().SetColors(primary, secondary, accent);
```

| Field | Default |
|---|---|
| `primary` | `#bb9c78` |
| `secondary` | `#937b64` |
| `accent` | `#788c8c` |

8780 triangles. Material: Object Lit, with the watercolor paper pattern. It responds to scene lights.
