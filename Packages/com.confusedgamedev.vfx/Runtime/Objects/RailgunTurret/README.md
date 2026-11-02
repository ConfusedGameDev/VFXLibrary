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
## Firing

`VfxObjectFiring` plays the shot: a charge and one hard slug beam with rings, 1.55 s, reaching 4 m. Press Play in its Inspector to see it without entering Play mode, or from code:

```csharp
var firing = GetComponent<VfxObjectFiring>();
firing.Fire();                         // straight ahead
firing.Fire(worldTarget: enemy.position);
firing.StopFire();
```

Turn on Detect Hits on `VfxObjectFiring` to end the beam and its rings on the first non-trigger collider in Hit Layers. It's off by default, and the shot still does no damage.
