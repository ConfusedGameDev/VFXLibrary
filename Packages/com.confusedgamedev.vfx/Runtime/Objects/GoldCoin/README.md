# Gold coin

Port of **Gold coin** (`gold-coin`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

A coin with a small emblem on each face makes a reward.

## Usage

Drop `GoldCoin.prefab` into a scene. The origin is the centre of the base, so it sits on the ground at Y 0. Units are meters.

Recolour it on the `VfxObject` component, or from code:

```csharp
GetComponent<VfxObject>().SetColors(primary, secondary, accent);
```

| Field | Default |
|---|---|
| `primary` | `#d9bd77` |
| `secondary` | `#bca16d` |
| `accent` | `#f1db98` |

368 triangles. Material: Object Lit, with the watercolor paper pattern. It responds to scene lights.
