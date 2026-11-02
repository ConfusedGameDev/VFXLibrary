# Objects

Game objects baked from the 00GameDevs object collection (MIT, see `THIRD-PARTY-NOTICES.md`). Each folder holds
a prefab, a mesh with one submesh per palette role, its materials and a README.

The source builds its models in JavaScript, so `Tools~/bake_objects.mjs` runs each module under Three.js and
writes its geometry, and `VfxObjectImporter` turns that into assets. To rebuild, see the comments in both.
Geometry converts by swapping X and Z, as the effects do, so a model facing +X on the site faces +Z here.

| Object | Category | Triangles |
|---|---|---:|
| [Angular rock](AngularRock/README.md) | nature | 1644 |
| [Arc turret](ArcTurret/README.md) | turrets | 12268 |
| [Battle axe](BattleAxe/README.md) | weapons | 4760 |
| [Bow](Bow/README.md) | weapons | 6488 |
| [Communications dish](CommunicationsDish/README.md) | sci-fi | 7252 |
| [Control console](ControlConsole/README.md) | sci-fi | 4144 |
| [Dagger](Dagger/README.md) | weapons | 2960 |
| [Data core](DataCore/README.md) | sci-fi | 2476 |
| [Energy cell](EnergyCell/README.md) | sci-fi | 4328 |
| [Energy pistol](EnergyPistol/README.md) | sci-fi | 4440 |
| [Energy shield device](EnergyShield/README.md) | sci-fi | 5540 |
| [Flower clump](FlowerClump/README.md) | plants | 924 |
| [Gemstone](Gemstone/README.md) | pickups | 2542 |
| [Gold coin](GoldCoin/README.md) | pickups | 368 |
| [Grass clump](GrassClump/README.md) | plants | 870 |
| [Handheld scanner](HandheldScanner/README.md) | sci-fi | 3188 |
| [Laser turret](LaserTurret/README.md) | turrets | 6704 |
| [Lightweight Sword](LightweightSword/README.md) | weapons | 42 |
| [Mechanical hatch](MechanicalHatch/README.md) | sci-fi | 3632 |
| [Missile](Missile/README.md) | sci-fi | 296 |
| [Missile turret](MissileTurret/README.md) | turrets | 13504 |
| [Pine tree](PineTree/README.md) | plants | 11486 |
| [Plasma dagger](PlasmaDagger/README.md) | sci-fi | 4622 |
| [Potion bottle](PotionBottle/README.md) | pickups | 3500 |
| [Pulse rifle](PulseRifle/README.md) | sci-fi | 7128 |
| [Railgun turret](RailgunTurret/README.md) | turrets | 8128 |
| [Reactor](Reactor/README.md) | sci-fi | 7144 |
| [Repair robot](RepairRobot/README.md) | sci-fi | 7632 |
| [Roof module](RoofModule/README.md) | building | 7816 |
| [Round canopy tree](RoundTree/README.md) | plants | 8028 |
| [Scout drone](ScoutDrone/README.md) | sci-fi | 8256 |
| [Shield](Shield/README.md) | weapons | 5782 |
| [Spear](Spear/README.md) | weapons | 5044 |
| [Staff](Staff/README.md) | weapons | 424 |
| [Stone arch](StoneArch/README.md) | building | 2336 |
| [Supply container](SupplyContainer/README.md) | sci-fi | 3596 |
| [Sword](Sword/README.md) | weapons | 4666 |
| [Thruster pack](ThrusterPack/README.md) | sci-fi | 6900 |
| [Treasure chest](TreasureChest/README.md) | pickups | 7404 |
| [Twin cannon turret](TwinCannonTurret/README.md) | turrets | 9408 |
| [War hammer](WarHammer/README.md) | weapons | 4996 |
| [Wooden barrel](WoodenBarrel/README.md) | furniture | 7864 |
| [Wooden chair](WoodenChair/README.md) | furniture | 2380 |
| [Wooden crate](WoodenCrate/README.md) | furniture | 5920 |
| [Wooden fence](WoodenFence/README.md) | building | 7812 |
| [Wooden table](WoodenTable/README.md) | furniture | 8780 |

## Firing

The pistol, the rifle and the five turrets carry `VfxObjectFiring`, a `VfxEffect` with one shot per `Fire`.

| Member | Use |
|---|---|
| `Fire(string pointId = null, Vector3? worldTarget = null)` | Restarts the shot. Every point fires, except the missile turret, which uses its next pod. An unknown point throws. |
| `StopFire()` | Ends the shot at once. |
| `IsPlaying`, `EffectTime`, `Preset.duration` | Shot state, from `VfxEffect`. |
| `RenderCamera` | Limits the draws to one camera. |

Calling `Play()` repeats the last shot's points and target.
Shots are drawn each frame with `Graphics.RenderMesh`, so they add no scene objects. The missile shrinks away at the end of its flight, where the source fades it, because its material is opaque.
Rerunning the object importer rebuilds the firing component with the prefab.
