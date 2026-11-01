# Missile turret

Port of **Missile turret** (`missile-turret`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

Two launch boxes show missile tips, with a sensor and support between them.

## Usage

Drop `MissileTurret.prefab` into a scene. The origin is the centre of the base, so it sits on the ground at Y 0. Units are meters.

Recolour it on the `VfxObject` component, or from code:

```csharp
GetComponent<VfxObject>().SetColors(primary, secondary, accent);
```

| Field | Default |
|---|---|
| `primary` | `#a5a28e` |
| `secondary` | `#353e43` |
| `accent` | `#edb66d` |

13504 triangles. Material: Object Lit, with metal and light roles. The Accent role glows. Its reflections come from your skybox and reflection probes, because the site's studio environment is not part of the object.

## Fire points

`VfxObject.FirePoints` lists `left-r1-c1`, `left-r1-c2`, `left-r1-c3`, `left-r2-c1`, `left-r2-c2`, `left-r2-c3`, `right-r1-c1`, `right-r1-c2`, `right-r1-c3`, `right-r2-c1`, `right-r2-c2`, `right-r2-c3` as child transforms. Each one aims along its own +Z.
The source's firing effects are not part of this object yet.
