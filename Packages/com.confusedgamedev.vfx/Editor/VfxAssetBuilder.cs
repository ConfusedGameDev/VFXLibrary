using System;
using System.IO;
using System.Reflection;
using UnityEditor;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Editor
{
    /// <summary>Marks a static method that rebuilds one effect's assets. The argument is the effect's folder name.</summary>
    [AttributeUsage(AttributeTargets.Method)]
    public sealed class VfxBuilderAttribute : Attribute
    {
        public VfxBuilderAttribute(string effect)
        {
            Effect = effect;
        }

        public string Effect { get; }
    }

    /// <summary>Regenerates an effect's baked meshes, materials, default preset and prefab.</summary>
    public static class VfxAssetBuilder
    {
        public readonly struct Layer
        {
            public readonly string name;
            public readonly Mesh mesh;

            public Layer(string name, Mesh mesh)
            {
                this.name = name;
                this.mesh = mesh;
            }
        }

        public static string PrefabPath(string effect)
        {
            return $"{AssetFolder(effect)}/{effect}.prefab";
        }

        public static void Rebuild(string effect)
        {
            foreach (MethodInfo method in TypeCache.GetMethodsWithAttribute<VfxBuilderAttribute>())
            {
                if (method.GetCustomAttribute<VfxBuilderAttribute>().Effect == effect)
                {
                    method.Invoke(null, null);
                }
            }
        }

        /// <summary>
        /// Layer materials use the shader "ConfusedGameDev/Vfx/{effect} {layer}". The returned object is
        /// saved afterwards with Save, so callers can wire their own fields first.
        /// </summary>
        public static GameObject Create<TEffect, TPreset>(string effect, Layer[] layers, out Renderer[] renderers)
            where TEffect : VfxEffect
            where TPreset : VfxPreset
        {
            string folder = AssetFolder(effect);
            Directory.CreateDirectory(folder);
            AssetDatabase.Refresh();

            string meshPath = $"{folder}/{effect}Meshes.asset";
            AssetDatabase.DeleteAsset(meshPath);
            AssetDatabase.CreateAsset(layers[0].mesh, meshPath);
            for (int i = 1; i < layers.Length; i++)
            {
                AssetDatabase.AddObjectToAsset(layers[i].mesh, layers[0].mesh);
            }

            string presetPath = $"{folder}/{effect}_Default.asset";
            var preset = AssetDatabase.LoadAssetAtPath<TPreset>(presetPath);
            if (preset == null)
            {
                preset = ScriptableObject.CreateInstance<TPreset>();
                AssetDatabase.CreateAsset(preset, presetPath);
            }

            var root = new GameObject(effect);
            renderers = new Renderer[layers.Length];
            for (int i = 0; i < layers.Length; i++)
            {
                renderers[i] = AddLayer(root, effect, layers[i]);
            }

            var serialized = new SerializedObject(root.AddComponent<TEffect>());
            serialized.FindProperty("preset").objectReferenceValue = preset;
            SerializedProperty list = serialized.FindProperty("renderers");
            list.arraySize = renderers.Length;
            for (int i = 0; i < renderers.Length; i++)
            {
                list.GetArrayElementAtIndex(i).objectReferenceValue = renderers[i];
            }
            serialized.ApplyModifiedPropertiesWithoutUndo();
            return root;
        }

        public static void Save(GameObject root, string effect)
        {
            PrefabUtility.SaveAsPrefabAsset(root, PrefabPath(effect));
            UnityEngine.Object.DestroyImmediate(root);
            AssetDatabase.SaveAssets();
        }

        private static string AssetFolder(string effect)
        {
            return $"Packages/com.confusedgamedev.vfx/Runtime/Effects/{effect}/Assets";
        }

        private static Renderer AddLayer(GameObject root, string effect, Layer layer)
        {
            var child = new GameObject(layer.name);
            child.transform.SetParent(root.transform, false);
            child.AddComponent<MeshFilter>().sharedMesh = layer.mesh;

            var renderer = child.AddComponent<MeshRenderer>();
            renderer.sharedMaterial = LoadMaterial(effect, layer.name);
            renderer.shadowCastingMode = UnityEngine.Rendering.ShadowCastingMode.Off;
            renderer.receiveShadows = false;
            renderer.lightProbeUsage = UnityEngine.Rendering.LightProbeUsage.Off;
            renderer.reflectionProbeUsage = UnityEngine.Rendering.ReflectionProbeUsage.Off;
            return renderer;
        }

        private static Material LoadMaterial(string effect, string layer)
        {
            string path = $"{AssetFolder(effect)}/{effect}{layer}.mat";
            var material = AssetDatabase.LoadAssetAtPath<Material>(path);
            if (material == null)
            {
                material = new Material(Shader.Find($"ConfusedGameDev/Vfx/{effect} {layer}"));
                AssetDatabase.CreateAsset(material, path);
            }
            return material;
        }
    }
}
