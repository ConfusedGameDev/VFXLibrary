# Laser turret

Port of **Laser turret** (`laser-turret`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

Rings surround the firing opening, with rows of thin cooling plates on both sides.

## Usage

Drop `LaserTurret.prefab` into a scene. The origin is the centre of the base, so it sits on the ground at Y 0. Units are meters.

Recolour it on the `VfxObject` component, or from code:

```csharp
GetComponent<VfxObject>().SetColors(primary, secondary, accent);
```

| Field | Default |
|---|---|
| `primary` | `#a5b2c0` |
| `secondary` | `#303b49` |
| `accent` | `#6cd9fa` |

6704 triangles. Material: Object Lit, with metal and light roles. The Accent role glows. Its reflections come from your skybox and reflection probes, because the site's studio environment is not part of the object.

## Fire points

`VfxObject.FirePoints` lists `laser-emitter` as child transforms. Each one aims along its own +Z.
## Firing

`VfxObjectFiring` plays the shot: a charge and a held beam, 1.8 s, reaching 3.4 m. Press Play in its Inspector to see it without entering Play mode, or from code:

```csharp
var firing = GetComponent<VfxObjectFiring>();
firing.Fire();                         // straight ahead
firing.Fire(worldTarget: enemy.position);
firing.StopFire();
```

This is the visual only. It does no damage and has no collision.
