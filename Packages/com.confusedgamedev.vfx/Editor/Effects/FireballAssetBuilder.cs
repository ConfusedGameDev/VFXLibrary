using System.IO;
using UnityEditor;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Editor
{
    /// <summary>Regenerates the fireball's baked meshes, materials, default preset and prefab.</summary>
    public static class FireballAssetBuilder
    {
        public const string AssetFolder = "Packages/com.confusedgamedev.vfx/Runtime/Effects/Fireball/Assets";
        public const string PrefabPath = AssetFolder + "/Fireball.prefab";

        private const string ShaderPrefix = "ConfusedGameDev/Vfx/Fireball ";

        [MenuItem("Tools/ConfusedGameDev/VFX/Rebuild Fireball Assets")]
        public static void Build()
        {
            Directory.CreateDirectory(AssetFolder);
            AssetDatabase.Refresh();

            string meshPath = AssetFolder + "/FireballMeshes.asset";
            AssetDatabase.DeleteAsset(meshPath);
            Mesh core = FireballMeshes.CreateCore();
            Mesh particles = FireballMeshes.CreateParticles();
            Mesh impact = FireballMeshes.CreateImpact();
            Mesh glow = FireballMeshes.CreateGlow();
            AssetDatabase.CreateAsset(core, meshPath);
            AssetDatabase.AddObjectToAsset(particles, core);
            AssetDatabase.AddObjectToAsset(impact, core);
            AssetDatabase.AddObjectToAsset(glow, core);

            string presetPath = AssetFolder + "/Fireball_Default.asset";
            var preset = AssetDatabase.LoadAssetAtPath<FireballPreset>(presetPath);
            if (preset == null)
            {
                preset = ScriptableObject.CreateInstance<FireballPreset>();
                AssetDatabase.CreateAsset(preset, presetPath);
            }

            var root = new GameObject("Fireball");
            Renderer coreRenderer = AddLayer(root, "Core", core);
            Renderer particleRenderer = AddLayer(root, "Particles", particles);
            Renderer impactRenderer = AddLayer(root, "Impact", impact);
            Renderer glowRenderer = AddLayer(root, "Glow", glow);

            var effect = root.AddComponent<FireballEffect>();
            var serialized = new SerializedObject(effect);
            serialized.FindProperty("preset").objectReferenceValue = preset;
            serialized.FindProperty("impactRenderer").objectReferenceValue = impactRenderer;
            serialized.FindProperty("glowRenderer").objectReferenceValue = glowRenderer;
            SerializedProperty renderers = serialized.FindProperty("renderers");
            Renderer[] layers = { coreRenderer, particleRenderer, impactRenderer, glowRenderer };
            renderers.arraySize = layers.Length;
            for (int i = 0; i < layers.Length; i++)
            {
                renderers.GetArrayElementAtIndex(i).objectReferenceValue = layers[i];
            }
            serialized.ApplyModifiedPropertiesWithoutUndo();

            impactRenderer.enabled = false;
            glowRenderer.enabled = false;

            PrefabUtility.SaveAsPrefabAsset(root, PrefabPath);
            Object.DestroyImmediate(root);
            AssetDatabase.SaveAssets();
        }

        private static Renderer AddLayer(GameObject root, string name, Mesh mesh)
        {
            var layer = new GameObject(name);
            layer.transform.SetParent(root.transform, false);
            layer.AddComponent<MeshFilter>().sharedMesh = mesh;

            var renderer = layer.AddComponent<MeshRenderer>();
            renderer.sharedMaterial = LoadMaterial(name);
            renderer.shadowCastingMode = UnityEngine.Rendering.ShadowCastingMode.Off;
            renderer.receiveShadows = false;
            renderer.lightProbeUsage = UnityEngine.Rendering.LightProbeUsage.Off;
            renderer.reflectionProbeUsage = UnityEngine.Rendering.ReflectionProbeUsage.Off;
            return renderer;
        }

        private static Material LoadMaterial(string layer)
        {
            string path = $"{AssetFolder}/Fireball{layer}.mat";
            var material = AssetDatabase.LoadAssetAtPath<Material>(path);
            if (material == null)
            {
                material = new Material(Shader.Find(ShaderPrefix + layer));
                AssetDatabase.CreateAsset(material, path);
            }
            return material;
        }
    }
}
