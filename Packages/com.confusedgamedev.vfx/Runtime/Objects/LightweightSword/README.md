# Lightweight Sword

Port of **Lightweight Sword** (`lightweight-sword`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

A pale slender blade, blue guard and dark grip—the same sword used in slash previews.

## Usage

Drop `LightweightSword.prefab` into a scene. The origin is the base of the hilt. Units are meters.

Recolour it on the `VfxObject` component, or from code:

```csharp
GetComponent<VfxObject>().SetColors(primary, secondary, accent);
```

| Field | Default |
|---|---|
| `primary` | `#d7ecf7` |
| `secondary` | `#354960` |
| `accent` | `#75a9d2` |

42 triangles. Material: Object Lit, set to unlit flat colours.
