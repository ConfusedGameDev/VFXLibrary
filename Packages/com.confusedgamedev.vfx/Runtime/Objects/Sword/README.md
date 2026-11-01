# Sword

Port of **Sword** (`sword`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

A long slender blade has a leather handle and a crossbar to protect the hand.

## Usage

Drop `Sword.prefab` into a scene. The origin is the grip, so parent it to a hand. The blade or head points along +Y. Units are meters.

Recolour it on the `VfxObject` component, or from code:

```csharp
GetComponent<VfxObject>().SetColors(primary, secondary, accent);
```

| Field | Default |
|---|---|
| `primary` | `#b8c9cc` |
| `secondary` | `#9b7a65` |
| `accent` | `#d2ba86` |

4666 triangles. Material: Object Lit, with the watercolor paper pattern. It responds to scene lights.
