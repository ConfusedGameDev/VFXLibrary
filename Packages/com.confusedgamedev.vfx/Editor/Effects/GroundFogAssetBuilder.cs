using UnityEditor;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Editor
{
    public static class GroundFogAssetBuilder
    {
        [VfxBuilder("GroundFog")]
        [MenuItem("Tools/ConfusedGameDev/VFX/Rebuild Ground-Hugging Mist Assets")]
        public static void Build()
        {
            GameObject root = VfxAssetBuilder.Create<GroundFogEffect, GroundFogPreset>("GroundFog", new[]
            {
                new VfxAssetBuilder.Layer("Clouds", GroundFogMeshes.CreateClouds())
            }, out _);
            VfxAssetBuilder.Save(root, "GroundFog");
        }
    }
}
