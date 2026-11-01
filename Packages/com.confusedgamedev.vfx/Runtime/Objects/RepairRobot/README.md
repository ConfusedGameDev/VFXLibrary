# Repair robot

Port of **Repair robot** (`repair-robot`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

A wheeled chassis carries tool arms, a sensor head and service panels. This model is static.

## Usage

Drop `RepairRobot.prefab` into a scene. The origin is the centre of the base, so it sits on the ground at Y 0. Units are meters.

Recolour it on the `VfxObject` component, or from code:

```csharp
GetComponent<VfxObject>().SetColors(primary, secondary, accent);
```

| Field | Default |
|---|---|
| `primary` | `#a9a18b` |
| `secondary` | `#354149` |
| `accent` | `#77dce1` |

7632 triangles. Material: Object Lit, with metal and light roles. The Accent role glows. Its reflections come from your skybox and reflection probes, because the site's studio environment is not part of the object.
