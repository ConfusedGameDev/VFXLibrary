# Railgun turret

Port of **Railgun turret** (`railgun-turret`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

Two long barrels gather light before firing two bright shots together.

## Usage

Drop `RailgunTurret.prefab` into a scene. The origin is the centre of the base, so it sits on the ground at Y 0. Units are meters.

Recolour it on the `VfxObject` component, or from code:

```csharp
GetComponent<VfxObject>().SetColors(primary, secondary, accent);
```

| Field | Default |
|---|---|
| `primary` | `#8194a0` |
| `secondary` | `#303c43` |
| `accent` | `#96e4d6` |

8128 triangles. Material: Object Lit, with metal and light roles. The Accent role glows. Its reflections come from your skybox and reflection probes, because the site's studio environment is not part of the object.

## Fire points

`VfxObject.FirePoints` lists `left-rail`, `right-rail` as child transforms. Each one aims along its own +Z.
The source's firing effects are not part of this object yet.
