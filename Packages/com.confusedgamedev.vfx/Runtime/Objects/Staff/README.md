# Staff

Port of **Staff** (`staff`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

One continuous shaft, one socket and one gem make a clear magic prop.

## Usage

Drop `Staff.prefab` into a scene. The origin is the grip, so parent it to a hand. The blade or head points along +Y. Units are meters.

Recolour it on the `VfxObject` component, or from code:

```csharp
GetComponent<VfxObject>().SetColors(primary, secondary, accent);
```

| Field | Default |
|---|---|
| `primary` | `#bbaa82` |
| `secondary` | `#998168` |
| `accent` | `#91b5c2` |

424 triangles. Material: Object Lit, with the watercolor paper pattern. It responds to scene lights.
