# Energy shield device

Port of **Energy shield device** (`energy-shield`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

Several shield plates protect the front, with a handle and battery behind them.

## Usage

Drop `EnergyShield.prefab` into a scene. The origin is the grip, so parent it to a hand. The blade or head points along +Y. Units are meters.

Recolour it on the `VfxObject` component, or from code:

```csharp
GetComponent<VfxObject>().SetColors(primary, secondary, accent);
```

| Field | Default |
|---|---|
| `primary` | `#8096a5` |
| `secondary` | `#303c49` |
| `accent` | `#63e3d1` |

5540 triangles. Material: Object Lit, with metal and light roles. The Accent role glows. Its reflections come from your skybox and reflection probes, because the site's studio environment is not part of the object.
