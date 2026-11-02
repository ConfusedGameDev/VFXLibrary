using UnityEditor;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Editor
{
    public static class SoulSiphonAssetBuilder
    {
        [VfxBuilder("SoulSiphon")]
        [MenuItem("Tools/ConfusedGameDev/VFX/Rebuild Dark Energy Siphon Assets")]
        public static void Build()
        {
            GameObject root = VfxAssetBuilder.Create<SoulSiphonEffect, SoulSiphonPreset>("SoulSiphon", new[]
            {
                new VfxAssetBuilder.Layer("Body", SoulSiphonMeshes.CreateBody()),
                new VfxAssetBuilder.Layer("Droplets", SoulSiphonMeshes.CreateDroplets())
            }, out _);

            VfxAssetBuilder.SaveBeam<SoulSiphonEffect>(root, "SoulSiphon");
        }
    }
}
