using UnityEditor;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Editor
{
    public static class DimensionalRendAssetBuilder
    {
        [VfxBuilder("DimensionalRend")]
        [MenuItem("Tools/ConfusedGameDev/VFX/Rebuild Rift-Shattering Slashes Assets")]
        public static void Build()
        {
            GameObject root = VfxAssetBuilder.Create<DimensionalRendEffect, DimensionalRendPreset>("DimensionalRend", new[]
            {
                new VfxAssetBuilder.Layer("Cuts", DimensionalRendMeshes.CreateCuts()),
                new VfxAssetBuilder.Layer("Glow", DimensionalRendMeshes.CreateGlow()),
                new VfxAssetBuilder.Layer("Shards", DimensionalRendMeshes.CreateShards()),
                new VfxAssetBuilder.Layer("Impact", DimensionalRendMeshes.CreateImpact())
            }, out _);
            VfxAssetBuilder.Save(root, "DimensionalRend");
        }
    }
}
