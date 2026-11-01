# Twin cannon turret

Port of **Twin cannon turret** (`twin-cannon-turret`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

Twin barrels and ammunition housings sit on a broad, low base.

## Usage

Drop `TwinCannonTurret.prefab` into a scene. The origin is the centre of the base, so it sits on the ground at Y 0. Units are meters.

Recolour it on the `VfxObject` component, or from code:

```csharp
GetComponent<VfxObject>().SetColors(primary, secondary, accent);
```

| Field | Default |
|---|---|
| `primary` | `#8b9b96` |
| `secondary` | `#303c41` |
| `accent` | `#ebae63` |

9408 triangles. Material: Object Lit, with metal and light roles. The Accent role glows. Its reflections come from your skybox and reflection probes, because the site's studio environment is not part of the object.

## Fire points

`VfxObject.FirePoints` lists `left-barrel`, `right-barrel` as child transforms. Each one aims along its own +Z.
The source's firing effects are not part of this object yet.
