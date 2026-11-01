# Mechanical hatch

Port of **Mechanical hatch** (`mechanical-hatch`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

Closed door panels sit inside a frame with rails and locking hardware.

## Usage

Drop `MechanicalHatch.prefab` into a scene. The origin is the centre of the base, so it sits on the ground at Y 0. Units are meters.

Recolour it on the `VfxObject` component, or from code:

```csharp
GetComponent<VfxObject>().SetColors(primary, secondary, accent);
```

| Field | Default |
|---|---|
| `primary` | `#9aabb5` |
| `secondary` | `#343d47` |
| `accent` | `#73d7ec` |

3632 triangles. Material: Object Lit, with metal and light roles. The Accent role glows. Its reflections come from your skybox and reflection probes, because the site's studio environment is not part of the object.
