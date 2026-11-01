# Data core

Port of **Data core** (`data-core`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

An angular shell with glowing lines and a plug makes a quest item to find.

## Usage

Drop `DataCore.prefab` into a scene. The origin is the centre of the base, so it sits on the ground at Y 0. Units are meters.

Recolour it on the `VfxObject` component, or from code:

```csharp
GetComponent<VfxObject>().SetColors(primary, secondary, accent);
```

| Field | Default |
|---|---|
| `primary` | `#a4a6ba` |
| `secondary` | `#323447` |
| `accent` | `#b59bff` |

2476 triangles. Material: Object Lit, with metal and light roles. The Accent role glows. Its reflections come from your skybox and reflection probes, because the site's studio environment is not part of the object.
