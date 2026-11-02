using System;
using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Editor
{
    /// <summary>
    /// Turns the output of Tools~/bake_objects.mjs into meshes, materials and prefabs under
    /// Runtime/Objects. Run with -executeMethod ConfusedGameDev.Vfx.Editor.VfxObjectImporter.Run.
    /// Environment: VFX_OBJECT_BAKE is the bake folder, VFX_OBJECT an optional comma-separated filter.
    /// </summary>
    public static class VfxObjectImporter
    {
        private const string Root = "Packages/com.confusedgamedev.vfx/Runtime/Objects";

        [Serializable]
        private class FirePointData
        {
            public string id;
            public float[] position;
            public float[] rotation;
        }

        [Serializable]
        private class RoleData
        {
            public int role;
            public int[] indices;
        }

        [Serializable]
        private class MeshData
        {
            public int vertexCount;
            public string position;
            public string normal;
            public string tone;
            public string uv;
            public string brushData;
            public string plantRoot;
            public string leafMotion;
            public RoleData[] roles;
        }

        [Serializable]
        private class BoundsData
        {
            public float[] min;
            public float[] max;
        }

        [Serializable]
        private class ObjectData
        {
            public string folder;
            public string family;
            public string primary;
            public string secondary;
            public string accent;
            public FirePointData[] firePoints;
            public BoundsData bounds;
            public MeshData mesh;
        }

        public static void Run()
        {
            string folder = Environment.GetEnvironmentVariable("VFX_OBJECT_BAKE");
            string filter = Environment.GetEnvironmentVariable("VFX_OBJECT");
            var only = string.IsNullOrEmpty(filter) ? null : new HashSet<string>(filter.Split(','));

            int count = 0;
            // Sorted, so the missile exists before the turret that launches it.
            string[] files = Directory.GetFiles(folder, "*.json");
            Array.Sort(files, StringComparer.Ordinal);
            foreach (string file in files)
            {
                string name = Path.GetFileNameWithoutExtension(file);
                if (only == null || only.Contains(name))
                {
                    Import(JsonUtility.FromJson<ObjectData>(File.ReadAllText(file)));
                    count++;
                }
            }

            AssetDatabase.SaveAssets();
            Debug.Log($"VfxObjectImporter finished: {count} objects");
        }

        private static void Import(ObjectData data)
        {
            string folder = $"{Root}/{data.folder}";
            Directory.CreateDirectory(folder);
            AssetDatabase.Refresh();

            Mesh mesh = BuildMesh(data);
            string meshPath = $"{folder}/{data.folder}Mesh.asset";
            AssetDatabase.DeleteAsset(meshPath);
            AssetDatabase.CreateAsset(mesh, meshPath);

            var root = new GameObject(data.folder);
            root.AddComponent<MeshFilter>().sharedMesh = mesh;
            var renderer = root.AddComponent<MeshRenderer>();
            renderer.sharedMaterials = BuildMaterials(data, folder);

            var effect = root.AddComponent<VfxObject>();
            var serialized = new SerializedObject(effect);
            SetColor(serialized, "primary", "defaultPrimary", data.primary);
            SetColor(serialized, "secondary", "defaultSecondary", data.secondary);
            SetColor(serialized, "accent", "defaultAccent", data.accent);

            if (data.family != "vegetation")
            {
                SerializedProperty roles = serialized.FindProperty("slotRoles");
                roles.arraySize = data.mesh.roles.Length;
                for (int i = 0; i < data.mesh.roles.Length; i++)
                {
                    roles.GetArrayElementAtIndex(i).intValue = data.mesh.roles[i].role;
                }
            }

            SerializedProperty points = serialized.FindProperty("firePoints");
            points.arraySize = data.firePoints?.Length ?? 0;
            for (int i = 0; i < points.arraySize; i++)
            {
                points.GetArrayElementAtIndex(i).objectReferenceValue = BuildFirePoint(root.transform, data.firePoints[i]);
            }
            serialized.ApplyModifiedPropertiesWithoutUndo();

            if (points.arraySize > 0)
            {
                AddFiring(root, data.folder, folder);
            }

            PrefabUtility.SaveAsPrefabAsset(root, $"{folder}/{data.folder}.prefab");
            UnityEngine.Object.DestroyImmediate(root);
        }

        private static void AddFiring(GameObject root, string name, string folder)
        {
            VfxFiringKind kind = KindOf(name);
            string presetPath = $"{folder}/{name}_Firing.asset";
            var preset = AssetDatabase.LoadAssetAtPath<VfxObjectFiringPreset>(presetPath);
            if (preset == null)
            {
                preset = ScriptableObject.CreateInstance<VfxObjectFiringPreset>();
                preset.duration = VfxObjectFiring.DurationOf(kind);
                AssetDatabase.CreateAsset(preset, presetPath);
            }

            var firing = new SerializedObject(root.AddComponent<VfxObjectFiring>());
            firing.FindProperty("preset").objectReferenceValue = preset;
            firing.FindProperty("playOnEnable").boolValue = false;
            firing.FindProperty("kind").enumValueIndex = (int)kind;
            firing.FindProperty("flatMaterial").objectReferenceValue = FiringMaterial("Flat", "ConfusedGameDev/Vfx/Object Firing", 0f, false);
            firing.FindProperty("glowMaterial").objectReferenceValue = FiringMaterial("Glow", "ConfusedGameDev/Vfx/Object Firing", 0f, true);
            firing.FindProperty("arcCoreMaterial").objectReferenceValue = FiringMaterial("ArcCore", "ConfusedGameDev/Vfx/Object Firing", 1f, false);
            firing.FindProperty("arcHaloMaterial").objectReferenceValue = FiringMaterial("ArcHalo", "ConfusedGameDev/Vfx/Object Firing", 2f, false);
            firing.FindProperty("smokeMaterial").objectReferenceValue = FiringMaterial("Smoke", "ConfusedGameDev/Vfx/Object Firing", 3f, false);
            firing.FindProperty("ribbonMaterial").objectReferenceValue = FiringMaterial("Ribbon", "ConfusedGameDev/Vfx/Object Firing Ribbon", 0f, false);

            if (kind == VfxFiringKind.Missile)
            {
                var missile = AssetDatabase.LoadAssetAtPath<GameObject>($"{Root}/Missile/Missile.prefab");
                firing.FindProperty("missileMesh").objectReferenceValue = missile.GetComponent<MeshFilter>().sharedMesh;
                Material[] materials = missile.GetComponent<MeshRenderer>().sharedMaterials;
                SerializedProperty list = firing.FindProperty("missileMaterials");
                list.arraySize = materials.Length;
                for (int i = 0; i < materials.Length; i++)
                {
                    list.GetArrayElementAtIndex(i).objectReferenceValue = materials[i];
                }
            }

            firing.ApplyModifiedPropertiesWithoutUndo();
        }

        private static VfxFiringKind KindOf(string name)
        {
            switch (name)
            {
                case "EnergyPistol": return VfxFiringKind.EnergyPistol;
                case "PulseRifle": return VfxFiringKind.PulseRifle;
                case "TwinCannonTurret": return VfxFiringKind.TwinCannon;
                case "LaserTurret": return VfxFiringKind.Laser;
                case "RailgunTurret": return VfxFiringKind.Railgun;
                case "MissileTurret": return VfxFiringKind.Missile;
                default: return VfxFiringKind.Arc;
            }
        }

        // Shared by every weapon. Colours and opacity arrive per draw.
        private static Material FiringMaterial(string name, string shader, float mode, bool additive)
        {
            string folder = $"{Root}/Firing";
            Directory.CreateDirectory(folder);
            AssetDatabase.Refresh();

            Material material = LoadMaterial($"{folder}/Firing{name}.mat", shader);
            if (material.HasProperty("_Mode"))
            {
                material.SetFloat("_Mode", mode);
                material.SetFloat("_SrcBlend", (float)UnityEngine.Rendering.BlendMode.SrcAlpha);
                material.SetFloat("_DstBlend", (float)(additive ? UnityEngine.Rendering.BlendMode.One : UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha));
                material.SetFloat("_Cull", (float)(mode > 0f ? UnityEngine.Rendering.CullMode.Off : UnityEngine.Rendering.CullMode.Back));
            }
            return material;
        }

        private static Mesh BuildMesh(ObjectData data)
        {
            MeshData source = data.mesh;
            var mesh = new Mesh { name = data.folder };
            mesh.indexFormat = source.vertexCount > 65000
                ? UnityEngine.Rendering.IndexFormat.UInt32
                : UnityEngine.Rendering.IndexFormat.UInt16;
            mesh.SetVertices(ToVectors3(Decode(source.position)));
            mesh.SetNormals(ToVectors3(Decode(source.normal)));

            if (data.family == "vegetation")
            {
                mesh.SetUVs(0, ToVectors2(Decode(source.uv)));
                mesh.SetUVs(1, ToVectors4(Decode(source.brushData)));
                mesh.SetUVs(2, ToVectors2(Decode(source.plantRoot)));
                mesh.SetUVs(3, ToVectors4(Decode(source.leafMotion)));
            }
            else
            {
                float[] tone = Decode(source.tone);
                var colors = new Color[tone.Length];
                for (int i = 0; i < tone.Length; i++)
                {
                    colors[i] = new Color(tone[i], tone[i], tone[i], 1f);
                }
                mesh.SetColors(colors);
            }

            // Swapping X and Z mirrors the mesh, so each triangle reverses to keep facing outward.
            mesh.subMeshCount = source.roles.Length;
            for (int i = 0; i < source.roles.Length; i++)
            {
                int[] indices = source.roles[i].indices;
                for (int t = 0; t + 2 < indices.Length; t += 3)
                {
                    (indices[t + 1], indices[t + 2]) = (indices[t + 2], indices[t + 1]);
                }
                mesh.SetTriangles(indices, i, false);
            }

            mesh.RecalculateBounds();
            if (data.bounds?.min != null && data.bounds.min.Length == 3)
            {
                // Falling leaves leave the static shape, so the source's animation bounds apply.
                Bounds bounds = mesh.bounds;
                bounds.Encapsulate(new Vector3(data.bounds.min[2], data.bounds.min[1], data.bounds.min[0]));
                bounds.Encapsulate(new Vector3(data.bounds.max[2], data.bounds.max[1], data.bounds.max[0]));
                bounds.Expand(new Vector3(0.32f, 0.04f, 0.32f));
                mesh.bounds = bounds;
            }
            mesh.UploadMeshData(false);
            return mesh;
        }

        private static Material[] BuildMaterials(ObjectData data, string folder)
        {
            string[] colors = { data.primary, data.secondary, data.accent };
            if (data.family == "vegetation")
            {
                Material plant = LoadMaterial($"{folder}/{data.folder}Plant.mat", "ConfusedGameDev/Vfx/Object Vegetation");
                plant.SetColor("_Primary", Parse(data.primary));
                plant.SetColor("_Secondary", Parse(data.secondary));
                plant.SetColor("_Accent", Parse(data.accent));
                plant.enableInstancing = true;
                return new[] { plant };
            }

            string[] names = { "Primary", "Secondary", "Accent" };
            var materials = new Material[data.mesh.roles.Length];
            for (int i = 0; i < materials.Length; i++)
            {
                int role = data.mesh.roles[i].role;
                Material material = LoadMaterial($"{folder}/{data.folder}{names[role]}.mat", "ConfusedGameDev/Vfx/Object Lit");
                material.SetColor("_BaseColor", Parse(colors[role]));
                ApplyFamily(material, data.family, role);
                material.enableInstancing = true;
                materials[i] = material;
            }
            return materials;
        }

        // Values from the source's createWatercolorMaterial and createSciFiMaterial.
        private static void ApplyFamily(Material material, string family, int role)
        {
            switch (family)
            {
                case "watercolor":
                    material.SetFloat("_Wash", 0.65f);
                    material.SetFloat("_Paper", 0.5f);
                    material.SetFloat("_Pigment", 0.55f);
                    break;
                case "scifi":
                    material.SetFloat("_Metallic", role == 0 ? 0.78f : role == 1 ? 0.12f : 0.18f);
                    material.SetFloat("_Smoothness", 1f - (role == 0 ? 0.31f : role == 1 ? 0.65f : 0.27f));
                    material.SetFloat("_Emission", role == 2 ? 1.15f : 0f);
                    break;
                default:
                    material.SetFloat("_Unlit", 1f);
                    break;
            }
        }

        private static Material LoadMaterial(string path, string shader)
        {
            var material = AssetDatabase.LoadAssetAtPath<Material>(path);
            if (material == null)
            {
                material = new Material(Shader.Find(shader));
                AssetDatabase.CreateAsset(material, path);
            }
            return material;
        }

        private static Transform BuildFirePoint(Transform root, FirePointData data)
        {
            var point = new GameObject(data.id).transform;
            point.SetParent(root, false);
            point.localPosition = new Vector3(data.position[2], data.position[1], data.position[0]);

            // Fire points aim along +Z in the source. Mirroring the axes keeps that aim on the same barrel.
            var rotation = new Quaternion(data.rotation[0], data.rotation[1], data.rotation[2], data.rotation[3]);
            Vector3 aim = rotation * Vector3.forward;
            Vector3 up = rotation * Vector3.up;
            point.localRotation = Quaternion.LookRotation(new Vector3(aim.z, aim.y, aim.x), new Vector3(up.z, up.y, up.x));
            return point;
        }

        private static void SetColor(SerializedObject serialized, string field, string defaultField, string hex)
        {
            Color color = Parse(hex);
            serialized.FindProperty(field).colorValue = color;
            serialized.FindProperty(defaultField).colorValue = color;
        }

        private static Color Parse(string hex)
        {
            ColorUtility.TryParseHtmlString(hex, out Color color);
            return color;
        }

        private static float[] Decode(string base64)
        {
            byte[] bytes = Convert.FromBase64String(base64);
            var values = new float[bytes.Length / 4];
            Buffer.BlockCopy(bytes, 0, values, 0, bytes.Length);
            return values;
        }

        private static Vector3[] ToVectors3(float[] values)
        {
            var vectors = new Vector3[values.Length / 3];
            for (int i = 0; i < vectors.Length; i++)
            {
                vectors[i] = new Vector3(values[i * 3 + 2], values[i * 3 + 1], values[i * 3]);
            }
            return vectors;
        }

        private static Vector2[] ToVectors2(float[] values)
        {
            var vectors = new Vector2[values.Length / 2];
            for (int i = 0; i < vectors.Length; i++)
            {
                vectors[i] = new Vector2(values[i * 2], values[i * 2 + 1]);
            }
            return vectors;
        }

        private static Vector4[] ToVectors4(float[] values)
        {
            var vectors = new Vector4[values.Length / 4];
            for (int i = 0; i < vectors.Length; i++)
            {
                vectors[i] = new Vector4(values[i * 4], values[i * 4 + 1], values[i * 4 + 2], values[i * 4 + 3]);
            }
            return vectors;
        }
    }
}
