using UnityEditor;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Editor
{
    public static class SmokeColumnAssetBuilder
    {
        [VfxBuilder("SmokeColumn")]
        [MenuItem("Tools/ConfusedGameDev/VFX/Rebuild Billowing Smoke Column Assets")]
        public static void Build()
        {
            GameObject root = VfxAssetBuilder.Create<SmokeColumnEffect, SmokeColumnPreset>("SmokeColumn", new[]
            {
                new VfxAssetBuilder.Layer("Clouds", SmokeColumnMeshes.CreateClouds())
            }, out _);
            VfxAssetBuilder.Save(root, "SmokeColumn");
        }
    }
}
