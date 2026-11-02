using NUnit.Framework;
using UnityEditor;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Tests
{
    public class VfxBeamEmitterTests
    {
        private GameObject root;
        private ContinuousBeamEffect effect;
        private Transform emitterA;
        private Transform emitterB;
        private GameObject wall;
        private Object[] previousSelection;

        [SetUp]
        public void SetUp()
        {
            previousSelection = Selection.objects;
            root = new GameObject("Beam");
            effect = root.AddComponent<ContinuousBeamEffect>();
            emitterA = new GameObject("A").transform;
            emitterB = new GameObject("B").transform;
            emitterA.SetParent(root.transform, false);
            emitterB.SetParent(root.transform, false);
            emitterA.position = new Vector3(1f, 0f, 0f);
            emitterB.position = new Vector3(1f, 0f, 10f);
        }

        [TearDown]
        public void TearDown()
        {
            GUIUtility.hotControl = 0;
            Selection.objects = previousSelection;
            Object.DestroyImmediate(root);
            if (wall != null)
            {
                Object.DestroyImmediate(wall);
            }
        }

        [TestCase("ArcRay")]
        [TestCase("ChargedBeam")]
        [TestCase("ContinuousBeam")]
        [TestCase("PulseBeam")]
        [TestCase("RadiantBeam")]
        [TestCase("SoulSiphon")]
        [TestCase("VenomStream")]
        public void Prefab_HasEmittersAtTheBeamEnds(string name)
        {
            var prefab = AssetDatabase.LoadAssetAtPath<VfxBeamEffect>($"Packages/com.confusedgamedev.vfx/Runtime/Effects/{name}/Assets/{name}.prefab");
            var serialized = new SerializedObject(prefab);

            var a = (Transform)serialized.FindProperty("emitterA").objectReferenceValue;
            var b = (Transform)serialized.FindProperty("emitterB").objectReferenceValue;

            Assert.That(a.localPosition.z, Is.EqualTo(-VfxBeamEffect.BaseLength * 0.5f));
            Assert.That(b.localPosition.z, Is.EqualTo(VfxBeamEffect.BaseLength * 0.5f));
            Assert.That(serialized.FindProperty("detectHits").boolValue, Is.False);
        }

        [Test]
        public void FollowEmitters_RunsTheBeamBetweenThem()
        {
            Assign(false);

            effect.FollowEmitters();

            AssertBeam(0f, 10f);
            Assert.That(emitterB.position, Is.EqualTo(new Vector3(1f, 0f, 10f)));
        }

        [Test]
        public void FollowEmitters_IgnoresCollidersWhenDetectionIsOff()
        {
            wall = CreateWall(LayerMask.NameToLayer("Default"));
            Assign(false);

            effect.FollowEmitters();

            AssertBeam(0f, 10f);
        }

        [Test]
        public void FollowEmitters_EndsOnTheFirstColliderInTheMask()
        {
            wall = CreateWall(LayerMask.NameToLayer("Default"));
            Assign(true);

            effect.FollowEmitters();

            AssertBeam(0f, 4.5f);
            Assert.That(emitterB.position, Is.EqualTo(new Vector3(1f, 0f, 10f)));
        }

        [Test]
        public void FollowEmitters_PassesCollidersOutsideTheMask()
        {
            wall = CreateWall(LayerMask.NameToLayer("Ignore Raycast"));
            Assign(true);

            effect.FollowEmitters();

            AssertBeam(0f, 10f);
        }

        [Test]
        public void SetEmitters_RunsTheBeamBetweenSceneTransforms()
        {
            wall = CreateWall(LayerMask.NameToLayer("Default"));

            effect.SetEmitters(emitterA, emitterB, true);

            AssertBeam(0f, 4.5f);
        }

        [Test]
        public void FollowEmitters_WaitsForAnEmitterDragToEnd()
        {
            Assign(false);
            effect.FollowEmitters();
            emitterB.position = new Vector3(1f, 0f, 12f);

            Selection.activeTransform = emitterB;
            GUIUtility.hotControl = 1;
            effect.FollowEmitters();
            Assert.That(effect.Length, Is.EqualTo(10f).Within(0.001f));

            GUIUtility.hotControl = 0;
            effect.FollowEmitters();
            AssertBeam(0f, 12f);
        }

        private void Assign(bool detectHits)
        {
            var serialized = new SerializedObject(effect);
            serialized.FindProperty("emitterA").objectReferenceValue = emitterA;
            serialized.FindProperty("emitterB").objectReferenceValue = emitterB;
            serialized.FindProperty("detectHits").boolValue = detectHits;
            serialized.FindProperty("hitLayers").intValue = LayerMask.GetMask("Default");
            serialized.ApplyModifiedPropertiesWithoutUndo();
        }

        private void AssertBeam(float startZ, float endZ)
        {
            Assert.That(root.transform.position.z, Is.EqualTo((startZ + endZ) * 0.5f).Within(0.001f));
            Assert.That(effect.Length, Is.EqualTo(endZ - startZ).Within(0.001f));
            Assert.That(emitterA.position.z, Is.EqualTo(startZ).Within(0.001f));
        }

        // A one-unit cube whose front face sits at z 4.5, on the beam's path.
        private static GameObject CreateWall(int layer)
        {
            GameObject cube = GameObject.CreatePrimitive(PrimitiveType.Cube);
            cube.transform.position = new Vector3(1f, 0f, 5f);
            cube.layer = layer;
            return cube;
        }
    }
}
