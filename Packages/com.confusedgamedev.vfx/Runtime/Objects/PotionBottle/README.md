# Potion bottle

Port of **Potion bottle** (`potion-bottle`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

Body, cork and label colors can identify different potions.

## Usage

Drop `PotionBottle.prefab` into a scene. The origin is the centre of the base, so it sits on the ground at Y 0. Units are meters.

Recolour it on the `VfxObject` component, or from code:

```csharp
GetComponent<VfxObject>().SetColors(primary, secondary, accent);
```

| Field | Default |
|---|---|
| `primary` | `#a19dbf` |
| `secondary` | `#cfb48d` |
| `accent` | `#d1c682` |

3500 triangles. Material: Object Lit, with the watercolor paper pattern. It responds to scene lights.
