# Pulse rifle

Port of **Pulse rifle** (`pulse-rifle`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

A long covered barrel fires three orange light shots each time.

## Usage

Drop `PulseRifle.prefab` into a scene. The origin is the grip, so parent it to a hand. The blade or head points along +Y. Units are meters.

Recolour it on the `VfxObject` component, or from code:

```csharp
GetComponent<VfxObject>().SetColors(primary, secondary, accent);
```

| Field | Default |
|---|---|
| `primary` | `#82908b` |
| `secondary` | `#283539` |
| `accent` | `#efb35c` |

7128 triangles. Material: Object Lit, with metal and light roles. The Accent role glows. Its reflections come from your skybox and reflection probes, because the site's studio environment is not part of the object.

## Fire points

`VfxObject.FirePoints` lists `rifle-muzzle` as child transforms. Each one aims along its own +Z.
The source's firing effects are not part of this object yet.
