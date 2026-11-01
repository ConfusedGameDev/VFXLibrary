# Handheld scanner

Port of **Handheld scanner** (`handheld-scanner`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

A grip supports a small screen and probe for exploration scenes.

## Usage

Drop `HandheldScanner.prefab` into a scene. The origin is the grip, so parent it to a hand. The blade or head points along +Y. Units are meters.

Recolour it on the `VfxObject` component, or from code:

```csharp
GetComponent<VfxObject>().SetColors(primary, secondary, accent);
```

| Field | Default |
|---|---|
| `primary` | `#b0b5aa` |
| `secondary` | `#374047` |
| `accent` | `#f0c469` |

3188 triangles. Material: Object Lit, with metal and light roles. The Accent role glows. Its reflections come from your skybox and reflection probes, because the site's studio environment is not part of the object.
