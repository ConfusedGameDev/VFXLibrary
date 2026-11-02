using System.Reflection;
using NUnit.Framework;
using UnityEditor;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Tests
{
    public class VfxProjectileHitTests
    {
        private const string PrefabPath = "Packages/com.confusedgamedev.vfx/Runtime/Effects/ArcaneMissile/Assets/ArcaneMissile.prefab";

        private ArcaneMissileEffect effect;
        private GameObject wall;

        [SetUp]
        public void SetUp()
        {
            var prefab = AssetDatabase.LoadAssetAtPath<ArcaneMissileEffect>(PrefabPath);
            effect = Object.Instantiate(prefab);
            effect.Play();
            effect.Tick(1f); // Past the start-up, so the contact point settles.
        }

        [TearDown]
        public void TearDown()
        {
            Object.DestroyImmediate(effect.gameObject);
            if (wall != null)
            {
                Object.DestroyImmediate(wall);
            }
        }

        [TestCase("ArcaneMissile")]
        [TestCase("ElectricMagicArrowStrike")]
        [TestCase("Fireball")]
        [TestCase("FrostWheel")]
        [TestCase("IceShard")]
        [TestCase("PlasmaBolt")]
        [TestCase("ShadowGlaive")]
        [TestCase("SpiralGale")]
        public void Prefab_HasAHitDetector(string name)
        {
            var prefab = AssetDatabase.LoadAssetAtPath<GameObject>($"Packages/com.confusedgamedev.vfx/Runtime/Effects/{name}/Assets/{name}.prefab");

            Assert.That(prefab.GetComponent<VfxProjectileHitDetector>(), Is.Not.Null);
        }

        [Test]
        public void EndEditPreview_RestoresTheImpactLayers()
        {
            Renderer impact = effect.transform.Find("Impact").GetComponent<Renderer>();
            Renderer glow = effect.transform.Find("Glow").GetComponent<Renderer>();

            effect.Hit();
            effect.Tick(0.01f);
            Assert.That(impact.enabled, Is.True);
            Assert.That(glow.transform.localPosition, Is.Not.EqualTo(Vector3.zero));

            effect.EndEditPreview();

            Assert.That(impact.enabled, Is.False);
            Assert.That(glow.enabled, Is.False);
            Assert.That(impact.transform.localPosition, Is.EqualTo(Vector3.zero));
            Assert.That(impact.transform.localRotation, Is.EqualTo(Quaternion.identity));
            Assert.That(glow.transform.localPosition, Is.EqualTo(Vector3.zero));
        }

        [Test]
        public void Sweep_HitsAWallWithTheLeadingSurface()
        {
            wall = CreateWall(3f);
            VfxProjectileHitDetector detector = AddDetector();

            effect.transform.position = new Vector3(0f, 0f, 2.5f);
            Physics.SyncTransforms();
            detector.Sweep();

            Assert.That(effect.State, Is.EqualTo(VfxState.Stopping));
            Assert.That(effect.ContactPosition.z, Is.EqualTo(2.5f).Within(0.0001f));
        }

        [Test]
        public void Sweep_IgnoresWallsBeyondTheLeadingSurface()
        {
            wall = CreateWall(10f);
            VfxProjectileHitDetector detector = AddDetector();

            Physics.SyncTransforms();
            detector.Sweep();

            Assert.That(effect.State, Is.EqualTo(VfxState.Playing));
        }

        private VfxProjectileHitDetector AddDetector()
        {
            if (!effect.TryGetComponent(out VfxProjectileHitDetector detector))
            {
                detector = effect.gameObject.AddComponent<VfxProjectileHitDetector>();
            }

            // Edit mode skips Awake, which normally finds the effect.
            FieldInfo field = typeof(VfxProjectileHitDetector).GetField("effect", BindingFlags.NonPublic | BindingFlags.Instance);
            field.SetValue(detector, effect);
            return detector;
        }

        // A one-unit cube, so its front face sits half a unit before z.
        private static GameObject CreateWall(float z)
        {
            GameObject cube = GameObject.CreatePrimitive(PrimitiveType.Cube);
            cube.transform.position = new Vector3(0f, 0f, z);
            return cube;
        }
    }
}
