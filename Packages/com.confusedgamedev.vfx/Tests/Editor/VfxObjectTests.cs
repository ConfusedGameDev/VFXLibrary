using System.Collections.Generic;
using NUnit.Framework;
using UnityEditor;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Tests
{
    public class VfxObjectTests
    {
        private const string Root = "Packages/com.confusedgamedev.vfx/Runtime/Objects";

        private static IEnumerable<string> Prefabs()
        {
            foreach (string guid in AssetDatabase.FindAssets("t:Prefab", new[] { Root }))
            {
                yield return AssetDatabase.GUIDToAssetPath(guid);
            }
        }

        [Test]
        public void EveryObject_HasOneMaterialPerSubMesh()
        {
            foreach (string path in Prefabs())
            {
                var prefab = AssetDatabase.LoadAssetAtPath<GameObject>(path);
                Mesh mesh = prefab.GetComponent<MeshFilter>().sharedMesh;
                Material[] materials = prefab.GetComponent<MeshRenderer>().sharedMaterials;

                Assert.That(mesh, Is.Not.Null, path);
                Assert.That(mesh.vertexCount, Is.GreaterThan(0), path);
                Assert.That(materials.Length, Is.EqualTo(mesh.subMeshCount), path);
                Assert.That(materials, Has.None.Null, path);
            }
        }

        [Test]
        public void EveryObject_StartsOnItsDefaultColors()
        {
            foreach (string path in Prefabs())
            {
                var prefab = AssetDatabase.LoadAssetAtPath<GameObject>(path);
                Assert.That(prefab.GetComponent<VfxObject>().UsesDefaultColors, Is.True, path);
            }
        }

        [Test]
        public void EveryFirePoint_IsAssigned()
        {
            foreach (string path in Prefabs())
            {
                var prefab = AssetDatabase.LoadAssetAtPath<GameObject>(path);
                Assert.That(prefab.GetComponent<VfxObject>().FirePoints, Has.None.Null, path);
            }
        }

        [Test]
        public void SetColors_LeavesTheSharedMaterialAlone()
        {
            var material = new Material(Shader.Find("ConfusedGameDev/Vfx/Object Lit"));
            material.SetColor("_BaseColor", Color.white);

            var gameObject = new GameObject("Object");
            gameObject.AddComponent<MeshFilter>();
            gameObject.AddComponent<MeshRenderer>().sharedMaterial = material;
            var effect = gameObject.AddComponent<VfxObject>();

            effect.SetColors(Color.red, Color.green, Color.blue);
            Assert.That(effect.UsesDefaultColors, Is.False);
            Assert.That(material.GetColor("_BaseColor"), Is.EqualTo(Color.white));

            effect.ResetColors();
            Assert.That(effect.UsesDefaultColors, Is.True);

            Object.DestroyImmediate(gameObject);
            Object.DestroyImmediate(material);
        }
    }
}
