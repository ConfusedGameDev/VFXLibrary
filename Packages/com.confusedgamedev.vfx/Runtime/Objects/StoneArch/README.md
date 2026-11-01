# Stone arch

Port of **Stone arch** (`stone-arch`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

An open passage fits a gateway or a ruin.

## Usage

Drop `StoneArch.prefab` into a scene. The origin is the centre of the base, so it sits on the ground at Y 0. Units are meters.

Recolour it on the `VfxObject` component, or from code:

```csharp
GetComponent<VfxObject>().SetColors(primary, secondary, accent);
```

| Field | Default |
|---|---|
| `primary` | `#b2b4a7` |
| `secondary` | `#919e98` |
| `accent` | `#c5bda7` |

2336 triangles. Material: Object Lit, with the watercolor paper pattern. It responds to scene lights.
