# Spear

Port of **Spear** (`spear`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

A long shaft has a leaf-shaped point and a central grip.

## Usage

Drop `Spear.prefab` into a scene. The origin is the grip, so parent it to a hand. The blade or head points along +Y. Units are meters.

Recolour it on the `VfxObject` component, or from code:

```csharp
GetComponent<VfxObject>().SetColors(primary, secondary, accent);
```

| Field | Default |
|---|---|
| `primary` | `#adc2c6` |
| `secondary` | `#a5896c` |
| `accent` | `#c9b68d` |

5044 triangles. Material: Object Lit, with the watercolor paper pattern. It responds to scene lights.
