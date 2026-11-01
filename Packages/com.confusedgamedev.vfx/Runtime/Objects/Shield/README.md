# Shield

Port of **Shield** (`shield`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

A face, rim and rear grip can be attached to a character hand.

## Usage

Drop `Shield.prefab` into a scene. The origin is the grip, so parent it to a hand. The blade or head points along +Y. Units are meters.

Recolour it on the `VfxObject` component, or from code:

```csharp
GetComponent<VfxObject>().SetColors(primary, secondary, accent);
```

| Field | Default |
|---|---|
| `primary` | `#8eaab2` |
| `secondary` | `#c9ae79` |
| `accent` | `#a88d71` |

5782 triangles. Material: Object Lit, with the watercolor paper pattern. It responds to scene lights.
