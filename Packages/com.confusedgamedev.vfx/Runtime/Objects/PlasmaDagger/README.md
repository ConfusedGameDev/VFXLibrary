# Plasma dagger

Port of **Plasma dagger** (`plasma-dagger`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

A solid blade carries a bright inset, with a guard above the grip.

## Usage

Drop `PlasmaDagger.prefab` into a scene. The origin is the grip, so parent it to a hand. The blade or head points along +Y. Units are meters.

Recolour it on the `VfxObject` component, or from code:

```csharp
GetComponent<VfxObject>().SetColors(primary, secondary, accent);
```

| Field | Default |
|---|---|
| `primary` | `#a4b8c7` |
| `secondary` | `#33394c` |
| `accent` | `#9f8dff` |

4622 triangles. Material: Object Lit, with metal and light roles. The Accent role glows. Its reflections come from your skybox and reflection probes, because the site's studio environment is not part of the object.
