# Showcase hall

A hall with every effect and object in the package, modelled on Unreal's content examples. Pick a category and its items run side by side in numbered bays.

## Requirements

- URP, with Opaque Texture on for the four effects that distort the scene.
- The Input System package, set as the active input handling.
- `ImpactFrameFeature` on your URP renderer, for bay 6.3.

## Use

In Package Manager, select ConfusedGameDev VFX, open the Samples tab and press Import next to Showcase Hall. It copies to `Assets/Samples/`. Open `Scenes/Showcase.unity` there and press Play.

| Input | Action |
|---|---|
| Menu category | Spawns that category's bays |
| Menu item | Flies to its bay and replays it |
| Replay all | Restarts every bay at once |
| WASD, Q, E | Move, down, up |
| Right-drag | Look |
| Middle-drag | Pan |
| Shift | Move faster |
| Tab | Hide or show the menu |

## How bays show each kind

| Category | Bay |
|---|---|
| Projectiles | A `VfxProjectileShooter` on a `PulseRifle`, with its shoot point at the muzzle, fires at a wall every 3 s. Shots are scaled to 0.4 to suit the rifle |
| Weapon effects | `LightweightSword` swings for the trails. For the sweeps its tip follows the arc's head, so the blade draws it |
| Beams | A `LaserTurret` runs the beam to a moving target, and Detect Hits stops it on a blocker |
| Ground and area effects | Placed on the floor. One-shots replay after a pause |
| Impact Frame | Fires every 4 s while the camera is within 8 m. It flashes the full screen, so it stops when you leave the bay |
| Weapons and turrets | Those that can fire do so on a timer. Laser and railgun shots end on a wall |
| Props | Placed on the floor |

Only the open category exists at runtime, so the hall never runs more than one category's effects together.

To add an item, add an entry to `Data/ShowcaseCatalog.asset`.

## Rebuild

`Tools > ConfusedGameDev > VFX > Build Showcase` regenerates the catalogue, materials and scene in the imported copy. The sample's tests check that the catalogue covers every effect and object.

To change the sample in this repository, import it, edit the copy under `Assets/Samples/`, then copy your changes back to `Samples~/Showcase/`. `Assets/Samples/` is ignored by git.
