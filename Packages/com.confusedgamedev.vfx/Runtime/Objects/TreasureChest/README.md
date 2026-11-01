# Treasure chest

Port of **Treasure chest** (`treasure-chest`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

A rounded lid, bands and clasp make treasure easy to spot.

## Usage

Drop `TreasureChest.prefab` into a scene. The origin is the centre of the base, so it sits on the ground at Y 0. Units are meters.

Recolour it on the `VfxObject` component, or from code:

```csharp
GetComponent<VfxObject>().SetColors(primary, secondary, accent);
```

| Field | Default |
|---|---|
| `primary` | `#a48465` |
| `secondary` | `#688187` |
| `accent` | `#d3b778` |

7404 triangles. Material: Object Lit, with the watercolor paper pattern. It responds to scene lights.
