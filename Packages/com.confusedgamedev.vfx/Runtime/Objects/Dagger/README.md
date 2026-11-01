# Dagger

Port of **Dagger** (`dagger`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

A short leaf-shaped blade has a handle held together by little pins.

## Usage

Drop `Dagger.prefab` into a scene. The origin is the grip, so parent it to a hand. The blade or head points along +Y. Units are meters.

Recolour it on the `VfxObject` component, or from code:

```csharp
GetComponent<VfxObject>().SetColors(primary, secondary, accent);
```

| Field | Default |
|---|---|
| `primary` | `#bbcbcb` |
| `secondary` | `#91766a` |
| `accent` | `#bca47d` |

2960 triangles. Material: Object Lit, with the watercolor paper pattern. It responds to scene lights.
