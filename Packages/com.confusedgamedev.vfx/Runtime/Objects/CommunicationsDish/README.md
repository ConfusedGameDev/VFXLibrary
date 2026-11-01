# Communications dish

Port of **Communications dish** (`communications-dish`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

A dish, feed receiver and support arms sit above an equipment box.

## Usage

Drop `CommunicationsDish.prefab` into a scene. The origin is the centre of the base, so it sits on the ground at Y 0. Units are meters.

Recolour it on the `VfxObject` component, or from code:

```csharp
GetComponent<VfxObject>().SetColors(primary, secondary, accent);
```

| Field | Default |
|---|---|
| `primary` | `#b7bdba` |
| `secondary` | `#35434b` |
| `accent` | `#eca85d` |

7252 triangles. Material: Object Lit, with metal and light roles. The Accent role glows. Its reflections come from your skybox and reflection probes, because the site's studio environment is not part of the object.
