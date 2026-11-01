# Energy pistol

Port of **Energy pistol** (`energy-pistol`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

A short gun has a glowing power pack and fires one blue-green light shot at a time.

## Usage

Drop `EnergyPistol.prefab` into a scene. The origin is the grip, so parent it to a hand. The blade or head points along +Y. Units are meters.

Recolour it on the `VfxObject` component, or from code:

```csharp
GetComponent<VfxObject>().SetColors(primary, secondary, accent);
```

| Field | Default |
|---|---|
| `primary` | `#8395aa` |
| `secondary` | `#293b4a` |
| `accent` | `#56d8ec` |

4440 triangles. Material: Object Lit, with metal and light roles. The Accent role glows. Its reflections come from your skybox and reflection probes, because the site's studio environment is not part of the object.

## Fire points

`VfxObject.FirePoints` lists `pistol-muzzle` as child transforms. Each one aims along its own +Z.
The source's firing effects are not part of this object yet.
