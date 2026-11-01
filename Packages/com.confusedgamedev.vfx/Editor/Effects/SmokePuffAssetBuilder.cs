using UnityEditor;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Editor
{
    public static class SmokePuffAssetBuilder
    {
        [VfxBuilder("SmokePuff")]
        [MenuItem("Tools/ConfusedGameDev/VFX/Rebuild Dispersing Smoke Puff Assets")]
        public static void Build()
        {
            GameObject root = VfxAssetBuilder.Create<SmokePuffEffect, SmokePuffPreset>("SmokePuff", new[]
            {
                new VfxAssetBuilder.Layer("Clouds", SmokePuffMeshes.CreateClouds())
            }, out _);
            VfxAssetBuilder.Save(root, "SmokePuff");
        }
    }
}
