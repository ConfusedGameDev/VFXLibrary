# Gemstone

Port of **Gemstone** (`gemstone`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

A colorful gem with clear edges makes a reward or treasure.

## Usage

Drop `Gemstone.prefab` into a scene. The origin is the centre of the base, so it sits on the ground at Y 0. Units are meters.

Recolour it on the `VfxObject` component, or from code:

```csharp
GetComponent<VfxObject>().SetColors(primary, secondary, accent);
```

| Field | Default |
|---|---|
| `primary` | `#82b9bd` |
| `secondary` | `#b9a083` |
| `accent` | `#d7d5b0` |

2542 triangles. Material: Object Lit, with the watercolor paper pattern. It responds to scene lights.
