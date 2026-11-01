# Thruster pack

Port of **Thruster pack** (`thruster-pack`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

Twin nozzles attach to a backplate with straps and supply lines.

## Usage

Drop `ThrusterPack.prefab` into a scene. The origin is the centre of the base, so it sits on the ground at Y 0. Units are meters.

Recolour it on the `VfxObject` component, or from code:

```csharp
GetComponent<VfxObject>().SetColors(primary, secondary, accent);
```

| Field | Default |
|---|---|
| `primary` | `#a49c8b` |
| `secondary` | `#363b41` |
| `accent` | `#ffb262` |

6900 triangles. Material: Object Lit, with metal and light roles. The Accent role glows. Its reflections come from your skybox and reflection probes, because the site's studio environment is not part of the object.
