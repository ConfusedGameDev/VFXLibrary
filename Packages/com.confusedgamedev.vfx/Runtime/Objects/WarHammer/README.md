# War hammer

Port of **War hammer** (`war-hammer`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

A thick metal hammer has flat ends and a long handle for a heavy fighter.

## Usage

Drop `WarHammer.prefab` into a scene. The origin is the grip, so parent it to a hand. The blade or head points along +Y. Units are meters.

Recolour it on the `VfxObject` component, or from code:

```csharp
GetComponent<VfxObject>().SetColors(primary, secondary, accent);
```

| Field | Default |
|---|---|
| `primary` | `#91a7af` |
| `secondary` | `#a28469` |
| `accent` | `#c4b68f` |

4996 triangles. Material: Object Lit, with the watercolor paper pattern. It responds to scene lights.
