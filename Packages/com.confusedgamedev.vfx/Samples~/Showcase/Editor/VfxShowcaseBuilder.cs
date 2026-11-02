using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.InputSystem.UI;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
using UnityEngine.SceneManagement;
using UnityEngine.UIElements;

namespace ConfusedGameDev.Vfx.Showcase.Editor
{
    /// <summary>Regenerates the catalogue, materials and hall scene in the imported sample.</summary>
    public static class VfxShowcaseBuilder
    {
        private const string BuilderSearch = nameof(VfxShowcaseBuilder) + " t:MonoScript";
        private const string DataFolderName = "Data";
        private const string SceneName = "Showcase.unity";
        private const string EffectsRoot = "Packages/com.confusedgamedev.vfx/Runtime/Effects";
        private const string ObjectsRoot = "Packages/com.confusedgamedev.vfx/Runtime/Objects";
        private const float HallHalfWidth = 10f;
        private const float HallHeight = 7f;
        private const float HallStart = -6f;
        private const float HallEnd = 126f;

        private static readonly string[] Projectiles = { "ArcaneMissile", "ElectricMagicArrowStrike", "Fireball", "FrostWheel", "IceShard", "PlasmaBolt", "ShadowGlaive", "SpiralGale" };
        private static readonly string[] Beams = { "ArcRay", "ChargedBeam", "ContinuousBeam", "PulseBeam", "RadiantBeam", "SoulSiphon", "VenomStream" };
        private static readonly string[] Ground =
        {
            "ArcaneMatrix", "BindingCurse", "BurningGround", "FrostField", "HealingField", "QuicksandSeal", "ThornCrown", "VenomPool", "MagicBarrier", "SpellIndicatorCircle", "SpellIndicatorSector",
            "DarkchainDetonation", "EnergyBurst", "FrostLanceRain", "GoldenChainRain", "MagmaFissure", "SacredRelicDescent", "Shockwave", "ThunderStrike"
        };
        private static readonly string[] Area =
        {
            "DustDevil", "EnergyVortex", "FireVortex", "WindVortex", "GroundFog", "SmokeColumn", "SteamJet", "PainterlyGrass", "BlackHole", "AstralGate",
            "AstralConvergence", "BillowingAirburst", "DimensionalRend", "FireExplosion", "FlameSurge", "IceShatter", "RevivalBloom", "SmokePuff", "TidalSurge"
        };
        private static readonly string[] Other = { "PrismGuard", "PrismParry", "ImpactFrame" };
        private static readonly string[] Weapons =
        {
            "EnergyPistol", "PulseRifle", "BattleAxe", "Bow", "Dagger", "EnergyShield", "HandheldScanner", "LightweightSword", "PlasmaDagger", "Shield", "Spear", "Staff", "Sword", "WarHammer"
        };
        private static readonly string[] Turrets = { "ArcTurret", "LaserTurret", "RailgunTurret", "TwinCannonTurret", "MissileTurret" };
        private static readonly string[] Props =
        {
            "RoofModule", "StoneArch", "WoodenFence", "WoodenBarrel", "WoodenChair", "WoodenCrate", "WoodenTable",
            "AngularRock", "FlowerClump", "GrassClump", "PineTree", "RoundTree", "Gemstone", "GoldCoin", "PotionBottle", "TreasureChest",
            "CommunicationsDish", "ControlConsole", "DataCore", "EnergyCell", "MechanicalHatch", "Missile", "Reactor", "RepairRobot", "ScoutDrone", "SupplyContainer", "ThrusterPack"
        };

        // READMEs place these above the floor: vortices and vapour sit 1.4 up, the burst's contact 1.2.
        private static readonly Dictionary<string, float> Heights = new Dictionary<string, float>
        {
            { "DustDevil", 1.4f }, { "EnergyVortex", 1.4f }, { "FireVortex", 1.4f }, { "WindVortex", 1.4f },
            { "GroundFog", 1.4f }, { "SmokeColumn", 1.4f }, { "SteamJet", 1.4f }, { "EnergyBurst", 1.2f }
        };

        // The black hole is 36 wide by default, far wider than a bay.
        private static readonly Dictionary<string, float> Scales = new Dictionary<string, float> { { "BlackHole", 0.2f } };

        /// <summary>Folders on disk that no category lists. Empty when the tables are complete.</summary>
        // The sample can be imported anywhere, so the folders are found from this script. It sits in Editor/.
        private static string Root => Path.GetDirectoryName(Path.GetDirectoryName(
            AssetDatabase.GUIDToAssetPath(AssetDatabase.FindAssets(BuilderSearch).First()))).Replace(Path.DirectorySeparatorChar, '/');

        private static string DataFolder => $"{Root}/{DataFolderName}";

        private static string ScenePath => $"{Root}/Scenes/{SceneName}";

        public static IEnumerable<string> Unclassified()
        {
            var listed = new HashSet<string>(Projectiles.Concat(Beams).Concat(Ground).Concat(Area).Concat(Other)
                .Concat(new[] { "WeaponSmear", "SpatialSmear", "AzureSweep", "SpatialSweep" })
                .Concat(Weapons).Concat(Turrets).Concat(Props));

            IEnumerable<string> folders = Directory.GetDirectories(Path.GetFullPath(EffectsRoot)).Concat(Directory.GetDirectories(Path.GetFullPath(ObjectsRoot)))
                .Select(Path.GetFileName)
                .Where(folder => folder != "Firing" && folder != "Shaders");
            return folders.Where(folder => !listed.Contains(folder));
        }

        [MenuItem("Tools/ConfusedGameDev/VFX/Build Showcase")]
        public static void Build()
        {
            foreach (string folder in Unclassified())
            {
                Debug.LogError($"{folder} has no showcase category. Add it to VfxShowcaseBuilder.");
            }

            VfxShowcaseCatalog catalog = BuildCatalog();
            Material surface = SaveMaterial("Surface", new Color(0.13f, 0.13f, 0.15f), 0.45f, null);
            Material panel = SaveMaterial("Panel", new Color(0.55f, 0.56f, 0.6f), 0.3f, null);
            Material trim = SaveMaterial("Trim", Color.black, 0f, new Color(1f, 0.55f, 0.1f) * 3f);
            Material label = SaveShaderMaterial("Label", Shader.Find("ConfusedGameDev/Showcase/Label"));

            BuildScene(catalog, surface, panel, trim, label);
        }

        private static VfxShowcaseCatalog BuildCatalog()
        {
            var catalog = LoadOrCreate<VfxShowcaseCatalog>($"{DataFolder}/ShowcaseCatalog.asset");
            catalog.categories = new List<VfxShowcaseCategory>
            {
                Effects("Projectiles", Projectiles, VfxShowcaseDisplay.Projectile),
                WeaponEffects(),
                Effects("Beams", Beams, VfxShowcaseDisplay.Beam),
                Effects("Ground effects", Ground, VfxShowcaseDisplay.Effect),
                Effects("Area effects", Area, VfxShowcaseDisplay.Effect),
                OtherEffects(),
                Objects("Weapons", Weapons, VfxShowcaseDisplay.Held),
                Objects("Turrets", Turrets, VfxShowcaseDisplay.Placed),
                Objects("Props", Props, VfxShowcaseDisplay.Placed)
            };
            catalog.shootingWeapon = ObjectPrefab("PulseRifle");
            catalog.beamTurret = ObjectPrefab("LaserTurret");
            catalog.sword = ObjectPrefab("LightweightSword");
            EditorUtility.SetDirty(catalog);
            AssetDatabase.SaveAssets();
            return catalog;
        }

        private static VfxShowcaseCategory Effects(string name, string[] folders, VfxShowcaseDisplay display)
        {
            return new VfxShowcaseCategory { name = name, items = folders.Select(folder => EffectItem(folder, display)).ToList() };
        }

        private static VfxShowcaseCategory WeaponEffects()
        {
            var category = new VfxShowcaseCategory { name = "Weapon effects" };
            category.items.Add(EffectItem("WeaponSmear", VfxShowcaseDisplay.Blade));
            category.items.Add(EffectItem("SpatialSmear", VfxShowcaseDisplay.Blade));
            category.items.Add(EffectItem("AzureSweep", VfxShowcaseDisplay.Sweep));
            category.items.Add(EffectItem("SpatialSweep", VfxShowcaseDisplay.Sweep));
            return category;
        }

        private static VfxShowcaseCategory OtherEffects()
        {
            var category = new VfxShowcaseCategory { name = "Other" };
            category.items.Add(EffectItem("PrismGuard", VfxShowcaseDisplay.Effect));
            category.items.Add(EffectItem("PrismParry", VfxShowcaseDisplay.Effect));
            category.items.Add(EffectItem("ImpactFrame", VfxShowcaseDisplay.ImpactFrame));
            return category;
        }

        private static VfxShowcaseItem EffectItem(string folder, VfxShowcaseDisplay display)
        {
            Heights.TryGetValue(folder, out float height);
            return new VfxShowcaseItem
            {
                name = ObjectNames.NicifyVariableName(folder),
                description = Describe($"{EffectsRoot}/{folder}/README.md"),
                display = display,
                prefab = display == VfxShowcaseDisplay.ImpactFrame ? null : Require($"{EffectsRoot}/{folder}/Assets/{folder}.prefab"),
                height = height,
                scale = Scales.TryGetValue(folder, out float scale) ? scale : 1f
            };
        }

        private static VfxShowcaseCategory Objects(string name, string[] folders, VfxShowcaseDisplay display)
        {
            return new VfxShowcaseCategory
            {
                name = name,
                objects = true,
                items = folders.Select(folder => new VfxShowcaseItem
                {
                    name = ObjectNames.NicifyVariableName(folder),
                    description = Describe($"{ObjectsRoot}/{folder}/README.md"),
                    display = display,
                    prefab = ObjectPrefab(folder)
                }).ToList()
            };
        }

        private static GameObject ObjectPrefab(string folder)
        {
            return Require($"{ObjectsRoot}/{folder}/{folder}.prefab");
        }

        private static GameObject Require(string path)
        {
            GameObject prefab = AssetDatabase.LoadAssetAtPath<GameObject>(path);
            if (prefab == null)
            {
                throw new InvalidOperationException($"Missing prefab {path}");
            }
            return prefab;
        }

        // The first prose paragraph after the port credit.
        private static string Describe(string readme)
        {
            if (!File.Exists(Path.GetFullPath(readme)))
            {
                return string.Empty;
            }

            string[] paragraphs = File.ReadAllText(Path.GetFullPath(readme)).Replace("\r", string.Empty).Split(new[] { "\n\n" }, StringSplitOptions.RemoveEmptyEntries);
            foreach (string paragraph in paragraphs.Skip(1))
            {
                string text = paragraph.Trim();
                if (!text.StartsWith("#") && !text.StartsWith("Port of") && !text.StartsWith("|") && !text.StartsWith("`"))
                {
                    return text.Replace('\n', ' ');
                }

                if (text.StartsWith("##"))
                {
                    break;
                }
            }
            return string.Empty;
        }

        private static void BuildScene(VfxShowcaseCatalog catalog, Material surface, Material panel, Material trim, Material label)
        {
            EnsureFolder(Root, "Scenes");

            // Built alongside the open scene, so unsaved work there is left alone. Unity can't add a scene
            // to an untitled one, but a blank one holds nothing to lose.
            UnityEngine.SceneManagement.Scene previous = SceneManager.GetActiveScene();
            bool replacesBlank = string.IsNullOrEmpty(previous.path) && !previous.isDirty;
            UnityEngine.SceneManagement.Scene scene = EditorSceneManager.NewScene(NewSceneSetup.EmptyScene, replacesBlank ? NewSceneMode.Single : NewSceneMode.Additive);
            SceneManager.SetActiveScene(scene);

            var hallObject = new GameObject("Hall");
            BuildGeometry(hallObject.transform, surface, trim);

            var light = new GameObject("Light").AddComponent<Light>();
            light.type = LightType.Directional;
            light.intensity = 1.2f;
            light.shadows = LightShadows.None;
            light.transform.rotation = Quaternion.Euler(60f, 30f, 0f);

            RenderSettings.ambientMode = AmbientMode.Flat;
            RenderSettings.ambientLight = new Color(0.45f, 0.45f, 0.5f);

            var cameraObject = new GameObject("Main Camera") { tag = "MainCamera" };
            var camera = cameraObject.AddComponent<Camera>();
            camera.clearFlags = CameraClearFlags.SolidColor;
            camera.backgroundColor = Color.black;
            camera.farClipPlane = 300f;
            cameraObject.AddComponent<UniversalAdditionalCameraData>().renderPostProcessing = true;
            cameraObject.AddComponent<AudioListener>();
            cameraObject.transform.SetPositionAndRotation(new Vector3(0f, 2.2f, -3f), Quaternion.identity);
            var flyCamera = cameraObject.AddComponent<VfxShowcaseFlyCamera>();

            var volume = new GameObject("Volume").AddComponent<Volume>();
            volume.isGlobal = true;
            volume.sharedProfile = BuildVolumeProfile();

            var hall = hallObject.AddComponent<VfxShowcaseHall>();
            var serialized = new SerializedObject(hall);
            serialized.FindProperty("catalog").objectReferenceValue = catalog;
            serialized.FindProperty("surfaceMaterial").objectReferenceValue = surface;
            serialized.FindProperty("targetMaterial").objectReferenceValue = panel;
            serialized.FindProperty("labelMaterial").objectReferenceValue = label;
            serialized.FindProperty("flyCamera").objectReferenceValue = flyCamera;
            serialized.ApplyModifiedPropertiesWithoutUndo();

            var menuObject = new GameObject("Menu");
            menuObject.AddComponent<UIDocument>().panelSettings = BuildPanelSettings();
            var menu = menuObject.AddComponent<VfxShowcaseMenu>();
            var serializedMenu = new SerializedObject(menu);
            serializedMenu.FindProperty("hall").objectReferenceValue = hall;
            serializedMenu.ApplyModifiedPropertiesWithoutUndo();

            var events = new GameObject("EventSystem");
            events.AddComponent<EventSystem>();
            events.AddComponent<InputSystemUIInputModule>();

            EditorSceneManager.SaveScene(scene, ScenePath);
            if (replacesBlank)
            {
                return;
            }

            SceneManager.SetActiveScene(previous);
            EditorSceneManager.CloseScene(scene, true);
        }

        private static void BuildGeometry(Transform parent, Material surface, Material trim)
        {
            float length = HallEnd - HallStart;
            float middle = (HallStart + HallEnd) * 0.5f;

            AddBox(parent, "Floor", new Vector3(0f, -0.5f, middle), new Vector3(HallHalfWidth * 2f, 1f, length), surface);
            AddBox(parent, "Ceiling", new Vector3(0f, HallHeight + 0.5f, middle), new Vector3(HallHalfWidth * 2f, 1f, length), surface);
            AddBox(parent, "Left wall", new Vector3(-HallHalfWidth - 0.5f, HallHeight * 0.5f, middle), new Vector3(1f, HallHeight, length), surface);
            AddBox(parent, "Right wall", new Vector3(HallHalfWidth + 0.5f, HallHeight * 0.5f, middle), new Vector3(1f, HallHeight, length), surface);
            AddBox(parent, "Near wall", new Vector3(0f, HallHeight * 0.5f, HallStart - 0.5f), new Vector3(HallHalfWidth * 2f, HallHeight, 1f), surface);
            AddBox(parent, "Far wall", new Vector3(0f, HallHeight * 0.5f, HallEnd + 0.5f), new Vector3(HallHalfWidth * 2f, HallHeight, 1f), surface);
            AddBox(parent, "Left trim", new Vector3(-HallHalfWidth + 0.05f, 6f, middle), new Vector3(0.1f, 0.06f, length), trim);
            AddBox(parent, "Right trim", new Vector3(HallHalfWidth - 0.05f, 6f, middle), new Vector3(0.1f, 0.06f, length), trim);
        }

        private static void AddBox(Transform parent, string name, Vector3 position, Vector3 size, Material material)
        {
            GameObject box = GameObject.CreatePrimitive(PrimitiveType.Cube);
            box.name = name;
            box.transform.SetParent(parent, false);
            box.transform.localPosition = position;
            box.transform.localScale = size;
            box.GetComponent<Renderer>().sharedMaterial = material;
        }

        private static VolumeProfile BuildVolumeProfile()
        {
            string path = $"{DataFolder}/ShowcaseVolume.asset";
            AssetDatabase.DeleteAsset(path);

            var profile = ScriptableObject.CreateInstance<VolumeProfile>();
            AssetDatabase.CreateAsset(profile, path);
            Bloom bloom = profile.Add<Bloom>();
            bloom.hideFlags = HideFlags.HideInHierarchy | HideFlags.HideInInspector;
            bloom.intensity.Override(0.6f);
            bloom.threshold.Override(1f);
            AssetDatabase.AddObjectToAsset(bloom, profile);
            AssetDatabase.SaveAssets();
            return profile;
        }

        private static PanelSettings BuildPanelSettings()
        {
            var settings = LoadOrCreate<PanelSettings>($"{DataFolder}/ShowcasePanel.asset");
            settings.themeStyleSheet = AssetDatabase.LoadAssetAtPath<ThemeStyleSheet>($"{DataFolder}/ShowcaseTheme.tss");
            settings.scaleMode = PanelScaleMode.ScaleWithScreenSize;
            settings.referenceResolution = new Vector2Int(1920, 1080);
            EditorUtility.SetDirty(settings);
            AssetDatabase.SaveAssets();
            return settings;
        }

        private static Material SaveMaterial(string name, Color color, float smoothness, Color? emission)
        {
            Material material = SaveShaderMaterial(name, Shader.Find("Universal Render Pipeline/Lit"));
            material.SetColor("_BaseColor", color);
            material.SetFloat("_Smoothness", smoothness);
            if (emission.HasValue)
            {
                material.EnableKeyword("_EMISSION");
                material.SetColor("_EmissionColor", emission.Value);
            }
            EditorUtility.SetDirty(material);
            return material;
        }

        private static Material SaveShaderMaterial(string name, Shader shader)
        {
            string path = $"{DataFolder}/Showcase{name}.mat";
            Material material = AssetDatabase.LoadAssetAtPath<Material>(path);
            if (material == null)
            {
                material = new Material(shader);
                AssetDatabase.CreateAsset(material, path);
            }

            material.shader = shader;
            return material;
        }

        private static T LoadOrCreate<T>(string path) where T : ScriptableObject
        {
            T asset = AssetDatabase.LoadAssetAtPath<T>(path);
            if (asset == null)
            {
                asset = ScriptableObject.CreateInstance<T>();
                AssetDatabase.CreateAsset(asset, path);
            }
            return asset;
        }

        private static void EnsureFolder(string parent, string name)
        {
            if (!AssetDatabase.IsValidFolder($"{parent}/{name}"))
            {
                AssetDatabase.CreateFolder(parent, name);
            }
        }
    }
}
