# Wooden chair

Port of **Wooden chair** (`wooden-chair`) from https://00gamedevs.com (MIT, see
`THIRD-PARTY-NOTICES.md` at the package root).

A chair with a back and rails suits rooms and camps.

## Usage

Drop `WoodenChair.prefab` into a scene. The origin is the centre of the base, so it sits on the ground at Y 0. Units are meters.

Recolour it on the `VfxObject` component, or from code:

```csharp
GetComponent<VfxObject>().SetColors(primary, secondary, accent);
```

| Field | Default |
|---|---|
| `primary` | `#b89a76` |
| `secondary` | `#917963` |
| `accent` | `#748884` |

2380 triangles. Material: Object Lit, with the watercolor paper pattern. It responds to scene lights.
