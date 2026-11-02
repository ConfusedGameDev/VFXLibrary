using NUnit.Framework;
using UnityEditor;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Tests
{
    public class VfxObjectFiringTests
    {
        private const string Root = "Packages/com.confusedgamedev.vfx/Runtime/Objects";

        private static VfxObjectFiring Spawn(string folder)
        {
            var prefab = AssetDatabase.LoadAssetAtPath<GameObject>($"{Root}/{folder}/{folder}.prefab");
            return Object.Instantiate(prefab).GetComponent<VfxObjectFiring>();
        }

        [TestCase("EnergyPistol", VfxFiringKind.EnergyPistol, 0.9f)]
        [TestCase("PulseRifle", VfxFiringKind.PulseRifle, 1.1f)]
        [TestCase("TwinCannonTurret", VfxFiringKind.TwinCannon, 1.65f)]
        [TestCase("LaserTurret", VfxFiringKind.Laser, 1.8f)]
        [TestCase("RailgunTurret", VfxFiringKind.Railgun, 1.55f)]
        [TestCase("MissileTurret", VfxFiringKind.Missile, 2.5f)]
        [TestCase("ArcTurret", VfxFiringKind.Arc, 2.2f)]
        public void Prefab_MatchesItsSourceShot(string folder, VfxFiringKind kind, float duration)
        {
            VfxObjectFiring firing = Spawn(folder);

            Assert.That(firing.Kind, Is.EqualTo(kind));
            Assert.That(firing.Preset.duration, Is.EqualTo(duration));
            Assert.That(firing.State, Is.EqualTo(VfxState.Idle));

            Object.DestroyImmediate(firing.gameObject);
        }

        [Test]
        public void Shot_EndsByItselfAndKeepsTheObject()
        {
            VfxObjectFiring firing = Spawn("EnergyPistol");

            firing.Fire();
            Assert.That(firing.IsPlaying, Is.True);

            for (int i = 0; i < 60; i++)
            {
                firing.Tick(1f / 60f);
            }

            Assert.That(firing.State, Is.EqualTo(VfxState.Finished));
            Assert.That(firing.gameObject.activeSelf, Is.True);

            Object.DestroyImmediate(firing.gameObject);
        }

        [Test]
        public void Turret_FiresEveryPointUnlessToldOne()
        {
            VfxObjectFiring firing = Spawn("TwinCannonTurret");

            firing.Fire();
            Assert.That(firing.ActivePointCount, Is.EqualTo(2));

            firing.Fire("left-barrel");
            Assert.That(firing.ActivePointCount, Is.EqualTo(1));

            Object.DestroyImmediate(firing.gameObject);
        }

        [Test]
        public void MissileTurret_LaunchesOnePodAtATime()
        {
            VfxObjectFiring firing = Spawn("MissileTurret");

            firing.Fire();
            Assert.That(firing.ActivePointCount, Is.EqualTo(1));

            Object.DestroyImmediate(firing.gameObject);
        }

        [Test]
        public void Fire_RejectsAnUnknownPoint()
        {
            VfxObjectFiring firing = Spawn("LaserTurret");

            Assert.Throws<System.ArgumentException>(() => firing.Fire("nowhere"));

            Object.DestroyImmediate(firing.gameObject);
        }

        [TestCase("LaserTurret", true, 1.5f)]
        [TestCase("RailgunTurret", true, 1.5f)]
        [TestCase("LaserTurret", false, 3.4f)]
        [TestCase("TwinCannonTurret", true, 3.4f)]
        public void ShotEnd_StopsAtTheFirstColliderWhenDetecting(string folder, bool detectHits, float distance)
        {
            VfxObjectFiring firing = Spawn(folder);
            var serialized = new SerializedObject(firing);
            serialized.FindProperty("detectHits").boolValue = detectHits;
            serialized.ApplyModifiedPropertiesWithoutUndo();

            Transform point = firing.GetComponent<VfxObject>().FirePoints[0];
            GameObject wall = GameObject.CreatePrimitive(PrimitiveType.Cube);
            wall.transform.SetPositionAndRotation(point.position + point.forward * 2f, point.rotation);
            Physics.SyncTransforms();

            float reached = Vector3.Distance(point.position, firing.ShotEnd(point));

            Assert.That(reached, Is.EqualTo(distance).Within(0.001f));

            Object.DestroyImmediate(wall);
            Object.DestroyImmediate(firing.gameObject);
        }
    }
}
