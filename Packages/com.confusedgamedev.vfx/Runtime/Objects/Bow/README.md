# Bow

Port of **Bow** (`bow`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

A curved wooden bow has a stitched grip and a string. It does not draw or shoot by itself.

## Usage

Drop `Bow.prefab` into a scene. The origin is the grip, so parent it to a hand. The blade or head points along +Y. Units are meters.

Recolour it on the `VfxObject` component, or from code:

```csharp
GetComponent<VfxObject>().SetColors(primary, secondary, accent);
```

| Field | Default |
|---|---|
| `primary` | `#b39373` |
| `secondary` | `#7b8e88` |
| `accent` | `#ded2aa` |

6488 triangles. Material: Object Lit, with the watercolor paper pattern. It responds to scene lights.
