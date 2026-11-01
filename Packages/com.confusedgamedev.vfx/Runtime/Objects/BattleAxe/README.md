# Battle axe

Port of **Battle axe** (`battle-axe`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

A curved axe blade sits on a wooden handle with a protective wrap.

## Usage

Drop `BattleAxe.prefab` into a scene. The origin is the grip, so parent it to a hand. The blade or head points along +Y. Units are meters.

Recolour it on the `VfxObject` component, or from code:

```csharp
GetComponent<VfxObject>().SetColors(primary, secondary, accent);
```

| Field | Default |
|---|---|
| `primary` | `#97b2b8` |
| `secondary` | `#a18467` |
| `accent` | `#d0c8aa` |

4760 triangles. Material: Object Lit, with the watercolor paper pattern. It responds to scene lights.
