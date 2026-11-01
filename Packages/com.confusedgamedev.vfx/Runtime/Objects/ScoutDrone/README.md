# Scout drone

Port of **Scout drone** (`scout-drone`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

A small flying craft has a sensor and protective frame. It does not fly by itself.

## Usage

Drop `ScoutDrone.prefab` into a scene. The origin is the centre of the base, so it sits on the ground at Y 0. Units are meters.

Recolour it on the `VfxObject` component, or from code:

```csharp
GetComponent<VfxObject>().SetColors(primary, secondary, accent);
```

| Field | Default |
|---|---|
| `primary` | `#8d9da9` |
| `secondary` | `#29373e` |
| `accent` | `#64e1df` |

8256 triangles. Material: Object Lit, with metal and light roles. The Accent role glows. Its reflections come from your skybox and reflection probes, because the site's studio environment is not part of the object.
