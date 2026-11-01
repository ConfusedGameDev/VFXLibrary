using UnityEditor;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Editor
{
    public static class ShockwaveAssetBuilder
    {
        [VfxBuilder("Shockwave")]
        [MenuItem("Tools/ConfusedGameDev/VFX/Rebuild Dust-Raising Shockwave Assets")]
        public static void Build()
        {
            GameObject root = VfxAssetBuilder.Create<ShockwaveEffect, ShockwavePreset>("Shockwave", new[]
            {
                new VfxAssetBuilder.Layer("Clouds", ShockwaveMeshes.CreateClouds()),
                new VfxAssetBuilder.Layer("Roll", ShockwaveMeshes.CreateRoll()),
                new VfxAssetBuilder.Layer("Fans", ShockwaveMeshes.CreateFans()),
                new VfxAssetBuilder.Layer("Wave", ShockwaveMeshes.CreateWave()),
                new VfxAssetBuilder.Layer("Sparks", ShockwaveMeshes.CreateSparks()),
                new VfxAssetBuilder.Layer("Chips", ShockwaveMeshes.CreateChips())
            }, out _);
            VfxAssetBuilder.Save(root, "Shockwave");
        }
    }
}
