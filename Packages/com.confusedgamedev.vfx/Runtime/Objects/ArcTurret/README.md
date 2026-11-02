# Arc turret

Port of **Arc turret** (`arc-turret`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

A fork-shaped cannon fires blue-white lightning with small branches and sparks on impact.

## Usage

Drop `ArcTurret.prefab` into a scene. The origin is the centre of the base, so it sits on the ground at Y 0. Units are meters.

Recolour it on the `VfxObject` component, or from code:

```csharp
GetComponent<VfxObject>().SetColors(primary, secondary, accent);
```

| Field | Default |
|---|---|
| `primary` | `#949db5` |
| `secondary` | `#343649` |
| `accent` | `#bd9aff` |

12268 triangles. Material: Object Lit, with metal and light roles. The Accent role glows. Its reflections come from your skybox and reflection probes, because the site's studio environment is not part of the object.

## Fire points

`VfxObject.FirePoints` lists `left-electrode`, `right-electrode` as child transforms. Each one aims along its own +Z.
## Firing

`VfxObjectFiring` plays the shot: a charge and a jagged electric arc with forks and impact sparks, 2.2 s, reaching 3.4 m. Press Play in its Inspector to see it without entering Play mode, or from code:

```csharp
var firing = GetComponent<VfxObjectFiring>();
firing.Fire();                         // straight ahead
firing.Fire(worldTarget: enemy.position);
firing.StopFire();
```

This is the visual only. It does no damage and has no collision.
