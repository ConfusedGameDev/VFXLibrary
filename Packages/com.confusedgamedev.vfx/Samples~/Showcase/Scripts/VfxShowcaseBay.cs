using System.Collections.Generic;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Showcase
{
    /// <summary>
    /// One numbered stop in the hall. Sets its item up for how it is meant to be seen, then keeps it
    /// going: one-shots replay after a pause, weapons keep firing. A bay's forward is along the hall.
    /// </summary>
    public sealed class VfxShowcaseBay : MonoBehaviour
    {
        private const float ReplayPause = 1.5f;
        private const float ShotInterval = 3f;
        private const float StandRadius = 0.06f;
        private const float MuzzleHeight = 1.2f;
        private const float RunStart = -2.5f;
        private const float RunEnd = 3f;
        private const float SwordScale = 0.5f;
        private const float MuzzleClearance = 0.05f;
        private const float ShotScale = 0.4f;
        private const float SlashHeight = 1.2f;
        private const float SlashTilt = 35f;
        private const float SlashReturnRate = 4f;
        private const float ImpactInterval = 4f;
        private const float ImpactViewRange = 8f;

        private readonly List<VfxProjectileEffect> shots = new List<VfxProjectileEffect>();

        private VfxShowcaseHall hall;
        private VfxEffect effect;
        private VfxObjectFiring firing;
        private VfxProjectileShooter shooter;
        private ImpactFrameTrigger impactFrame;
        private Transform movingTarget;
        private Transform swingPivot;
        private VfxSweepEffect sweep;
        private float nextAction;

        public VfxShowcaseItem Item { get; private set; }

        /// <summary>The effect on show, if the bay keeps one in the scene.</summary>
        public VfxEffect Effect => effect;

        /// <summary>Shots in flight or playing their impact.</summary>
        public int ActiveShots => shots.Count;

        public void Build(VfxShowcaseHall owner, VfxShowcaseItem item)
        {
            hall = owner;
            Item = item;

            switch (item.display)
            {
                case VfxShowcaseDisplay.Projectile:
                    BuildProjectile();
                    break;
                case VfxShowcaseDisplay.Beam:
                    BuildBeam();
                    break;
                case VfxShowcaseDisplay.Blade:
                    BuildBlade();
                    break;
                case VfxShowcaseDisplay.Sweep:
                    BuildSweep();
                    break;
                case VfxShowcaseDisplay.Effect:
                    AddEffect(item.prefab);
                    break;
                case VfxShowcaseDisplay.ImpactFrame:
                    BuildImpactFrame();
                    break;
                case VfxShowcaseDisplay.Held:
                    AddBox(new Vector3(0f, 0.5f, 0f), new Vector3(StandRadius * 2f, 1f, StandRadius * 2f), hall.SurfaceMaterial);
                    AddObject(item.prefab, Vector3.up);
                    break;
                case VfxShowcaseDisplay.Placed:
                    BuildPlaced();
                    break;
            }
        }

        /// <summary>Starts the bay's show over, right now.</summary>
        public void Replay()
        {
            nextAction = 0f;

            // An impact frame fills the screen, so Update waits until the camera has arrived.
            if (effect != null)
            {
                effect.Play();
            }
        }

        private void BuildProjectile()
        {
            GameObject weapon = Instantiate(hall.Catalog.shootingWeapon, transform);
            Transform muzzle = weapon.GetComponent<VfxObject>().FirePoints[0];
            Aim(weapon.transform, muzzle, new Vector3(0f, MuzzleHeight, RunStart));

            Vector3 grip = weapon.transform.localPosition;
            AddBox(new Vector3(grip.x, grip.y * 0.5f, grip.z), new Vector3(StandRadius * 2f, grip.y, StandRadius * 2f), hall.SurfaceMaterial);

            var shootPoint = new GameObject("ShootPoint").transform;
            shootPoint.SetParent(muzzle, false);
            shootPoint.localPosition = Vector3.forward * MuzzleClearance;

            // Projectiles are built about 2 m long, twice the rifle, so a full-size shot would swallow it.
            shooter = weapon.AddComponent<VfxProjectileShooter>();
            shooter.Projectile = Item.prefab.GetComponent<VfxProjectileEffect>();
            shooter.ShootPoint = shootPoint;
            shooter.ShotScale = ShotScale;

            AddBox(new Vector3(0f, MuzzleHeight, RunEnd), new Vector3(3f, 2.4f, 0.2f), hall.TargetMaterial);
        }

        // Points a fire point down the bay and puts it at a local position, turning its whole object.
        private void Aim(Transform weapon, Transform point, Vector3 localPosition)
        {
            weapon.rotation = Quaternion.LookRotation(transform.forward, Vector3.up) * Quaternion.Inverse(point.rotation) * weapon.rotation;
            weapon.position += transform.TransformPoint(localPosition) - point.position;
        }

        // Turrets fire along +X and hand weapons along +Z, so each is turned to face down the bay.
        private void Face(Transform weapon, Transform point)
        {
            weapon.rotation = Quaternion.FromToRotation(point.forward, transform.forward) * weapon.rotation;
        }

        private void BuildBeam()
        {
            GameObject turret = Instantiate(hall.Catalog.beamTurret, transform);
            turret.transform.localPosition = new Vector3(0f, 0f, RunStart);
            Transform muzzle = turret.GetComponent<VfxObject>().FirePoints[0];
            Face(turret.transform, muzzle);

            movingTarget = GameObject.CreatePrimitive(PrimitiveType.Sphere).transform;
            Destroy(movingTarget.GetComponent<Collider>());
            movingTarget.SetParent(transform, false);
            movingTarget.localScale = Vector3.one * 0.2f;
            movingTarget.localPosition = new Vector3(0f, muzzle.position.y, RunEnd);
            movingTarget.GetComponent<Renderer>().sharedMaterial = hall.TargetMaterial;

            AddBox(new Vector3(1.1f, 1.5f, 1f), new Vector3(1f, 3f, 0.2f), hall.TargetMaterial);

            var beam = Instantiate(Item.prefab, transform).GetComponent<VfxBeamEffect>();
            beam.SetEmitters(muzzle, movingTarget, true);
            effect = beam;
        }

        private void BuildBlade()
        {
            swingPivot = new GameObject("Swing").transform;
            swingPivot.SetParent(transform, false);
            swingPivot.localPosition = Vector3.up * 1.2f;
            Transform sword = AddSword(swingPivot, Vector3.zero);

            // The trail stays outside the weapon's hierarchy, or it would swing along with it.
            effect = Instantiate(Item.prefab, transform).GetComponent<VfxEffect>();
            float reach = sword.GetComponentInChildren<MeshFilter>().sharedMesh.bounds.max.z;
            ((VfxBladeTrailEffect)effect).AttachWeapon(sword, Vector3.forward * reach * 0.3f, Vector3.forward * reach);
        }

        // The sword's blade runs 3 m along +Z, so it is stood up and brought down to hand size.
        private Transform AddSword(Transform parent, Vector3 localPosition)
        {
            GameObject sword = Instantiate(hall.Catalog.sword, parent);
            sword.transform.localPosition = localPosition;
            sword.transform.localRotation = Quaternion.Euler(-90f, 0f, 0f);
            sword.transform.localScale = Vector3.one * SwordScale;
            return sword.transform;
        }

        // The sword and the arc share a center and a reach, so the blade's tip draws the arc's head.
        private void BuildSweep()
        {
            var slash = new GameObject("Slash").transform;
            slash.SetParent(transform, false);
            slash.localPosition = Vector3.up * SlashHeight;

            // Leaned toward the aisle, so the viewer sees the circle and not just its edge.
            Vector3 toAisle = Vector3.right * -Mathf.Sign(transform.position.x);
            slash.rotation = Quaternion.AngleAxis(SlashTilt, Vector3.Cross(Vector3.up, toAisle));

            AddEffect(Item.prefab);
            sweep = (VfxSweepEffect)effect;
            sweep.transform.SetParent(slash, false);
            sweep.transform.localScale = Vector3.one * SwordScale;
            sweep.transform.localPosition = -sweep.Center * SwordScale;

            swingPivot = new GameObject("Swing").transform;
            swingPivot.SetParent(slash, false);
            swingPivot.localRotation = Quaternion.Euler(0f, sweep.StartYaw, 0f);
            AddSword(swingPivot, Vector3.zero).localRotation = Quaternion.identity;
        }

        private void BuildImpactFrame()
        {
            impactFrame = gameObject.AddComponent<ImpactFrameTrigger>();
            Transform subject = GameObject.CreatePrimitive(PrimitiveType.Sphere).transform;
            subject.SetParent(transform, false);
            subject.localPosition = Vector3.up;
            subject.GetComponent<Renderer>().sharedMaterial = hall.TargetMaterial;
            impactFrame.subjects = new[] { subject.GetComponent<Renderer>() };
        }

        private void BuildPlaced()
        {
            GameObject placed = AddObject(Item.prefab, Vector3.zero);
            if (firing == null || (firing.Kind != VfxFiringKind.Laser && firing.Kind != VfxFiringKind.Railgun))
            {
                return;
            }

            // A wall inside the shot's reach, so the beam can be seen ending on it.
            firing.DetectHits = true;
            placed.transform.localPosition = new Vector3(0f, 0f, RunStart);
            AddBox(new Vector3(0f, 1.5f, RunEnd - 2.5f), new Vector3(3f, 3f, 0.2f), hall.TargetMaterial);
        }

        private GameObject AddObject(GameObject prefab, Vector3 localPosition)
        {
            GameObject instance = Instantiate(prefab, transform);
            instance.transform.localPosition = localPosition;
            firing = instance.GetComponent<VfxObjectFiring>();
            if (firing != null)
            {
                Face(instance.transform, instance.GetComponent<VfxObject>().FirePoints[0]);
            }
            return instance;
        }

        private void AddEffect(GameObject prefab)
        {
            GameObject instance = Instantiate(prefab, transform);
            instance.transform.localPosition = Vector3.up * Item.height;
            instance.transform.localScale *= Item.scale;
            effect = instance.GetComponent<VfxEffect>();
        }

        private void AddBox(Vector3 localPosition, Vector3 size, Material material)
        {
            Transform box = GameObject.CreatePrimitive(PrimitiveType.Cube).transform;
            box.SetParent(transform, false);
            box.localPosition = localPosition;
            box.localScale = size;
            box.GetComponent<Renderer>().sharedMaterial = material;
        }

        private void Update()
        {
            if (movingTarget != null)
            {
                Vector3 position = movingTarget.localPosition;
                position.x = Mathf.Sin(Time.time * 0.6f) * 2f;
                movingTarget.localPosition = position;
            }

            if (swingPivot != null && sweep == null)
            {
                // Along the hall, so the swing faces a viewer standing in the aisle.
                swingPivot.localRotation = Quaternion.Euler(Mathf.Sin(Time.time * 3f) * 75f, 0f, 0f);
            }

            shots.RemoveAll(shot => shot == null);

            if (impactFrame != null)
            {
                Vector3 center = Camera.main.WorldToViewportPoint(transform.position + Vector3.up);
                if (Time.time >= nextAction && center.z > 0f && center.z < ImpactViewRange)
                {
                    nextAction = Time.time + ImpactInterval;
                    impactFrame.Fire(new Vector2(center.x, center.y));
                }
            }
            else if (shooter != null)
            {
                if (Time.time >= nextAction)
                {
                    nextAction = Time.time + ShotInterval;
                    shots.Add(shooter.Shoot());
                }
            }
            else if (firing != null)
            {
                if (!firing.IsPlaying && Time.time >= nextAction)
                {
                    nextAction = Time.time + firing.Preset.duration + ReplayPause;
                    firing.Fire();
                }
            }
            else if (effect != null && effect.State == VfxState.Finished)
            {
                if (nextAction == 0f)
                {
                    nextAction = Time.time + ReplayPause;
                }
                else if (Time.time >= nextAction)
                {
                    nextAction = 0f;
                    effect.Play();
                }
            }
        }

        // After the effects have updated, so the blade is on the head this frame and not the last.
        private void LateUpdate()
        {
            if (sweep == null)
            {
                return;
            }

            float blend = 1f - Mathf.Exp(-SlashReturnRate * Time.deltaTime);
            float yaw = sweep.IsPlaying ? sweep.HeadYaw : Mathf.LerpAngle(swingPivot.localEulerAngles.y, sweep.StartYaw, blend);
            swingPivot.localRotation = Quaternion.Euler(0f, yaw, 0f);
        }

        // Shots live outside the bay, and would otherwise outlast its wall.
        private void OnDestroy()
        {
            foreach (VfxProjectileEffect shot in shots)
            {
                if (shot != null)
                {
                    Destroy(shot.gameObject);
                }
            }
        }
    }
}
