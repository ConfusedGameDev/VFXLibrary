using UnityEditor;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Editor
{
    public static class IceShatterAssetBuilder
    {
        [VfxBuilder("IceShatter")]
        [MenuItem("Tools/ConfusedGameDev/VFX/Rebuild Shattering Frostburst Assets")]
        public static void Build()
        {
            GameObject root = VfxAssetBuilder.Create<IceShatterEffect, IceShatterPreset>("IceShatter", new[]
            {
                new VfxAssetBuilder.Layer("Clouds", IceShatterMeshes.CreateClouds()),
                new VfxAssetBuilder.Layer("Crystals", IceShatterMeshes.CreateCrystals()),
                new VfxAssetBuilder.Layer("Shards", IceShatterMeshes.CreateShards()),
                new VfxAssetBuilder.Layer("Wave", IceShatterMeshes.CreateWave()),
                new VfxAssetBuilder.Layer("Sparks", IceShatterMeshes.CreateSparks())
            }, out _);
            VfxAssetBuilder.Save(root, "IceShatter");
        }
    }
}
