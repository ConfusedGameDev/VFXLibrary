using UnityEditor;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Editor
{
    public static class AzureSweepAssetBuilder
    {
        [VfxBuilder("AzureSweep")]
        [MenuItem("Tools/ConfusedGameDev/VFX/Rebuild Azure Blade Sweep Assets")]
        public static void Build()
        {
            GameObject root = VfxAssetBuilder.Create<AzureSweepEffect, AzureSweepPreset>("AzureSweep", new[]
            {
                new VfxAssetBuilder.Layer("Blade", AzureSweepMeshes.CreateBlade()),
                new VfxAssetBuilder.Layer("Halo", AzureSweepMeshes.CreateHalo()),
                new VfxAssetBuilder.Layer("Streaks", AzureSweepMeshes.CreateStreaks()),
                new VfxAssetBuilder.Layer("Edge", AzureSweepMeshes.CreateEdge())
            }, out _);
            VfxAssetBuilder.Save(root, "AzureSweep");
        }
    }
}
