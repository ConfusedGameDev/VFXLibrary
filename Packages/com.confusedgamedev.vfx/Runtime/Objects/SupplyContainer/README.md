# Supply container

Port of **Supply container** (`supply-container`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

Reinforced corners, locks and inset handles fit a base or cargo hold.

## Usage

Drop `SupplyContainer.prefab` into a scene. The origin is the centre of the base, so it sits on the ground at Y 0. Units are meters.

Recolour it on the `VfxObject` component, or from code:

```csharp
GetComponent<VfxObject>().SetColors(primary, secondary, accent);
```

| Field | Default |
|---|---|
| `primary` | `#9d9987` |
| `secondary` | `#343e43` |
| `accent` | `#83d9c7` |

3596 triangles. Material: Object Lit, with metal and light roles. The Accent role glows. Its reflections come from your skybox and reflection probes, because the site's studio environment is not part of the object.
