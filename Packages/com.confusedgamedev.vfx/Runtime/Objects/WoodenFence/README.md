# Wooden fence

Port of **Wooden fence** (`wooden-fence`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

Pointed boards and crossbars mark farms and gardens.

## Usage

Drop `WoodenFence.prefab` into a scene. The origin is the centre of the base, so it sits on the ground at Y 0. Units are meters.

Recolour it on the `VfxObject` component, or from code:

```csharp
GetComponent<VfxObject>().SetColors(primary, secondary, accent);
```

| Field | Default |
|---|---|
| `primary` | `#b49370` |
| `secondary` | `#927960` |
| `accent` | `#6a7d82` |

7812 triangles. Material: Object Lit, with the watercolor paper pattern. It responds to scene lights.
