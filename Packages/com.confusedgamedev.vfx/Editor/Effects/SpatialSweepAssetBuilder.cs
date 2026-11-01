using UnityEditor;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Editor
{
    public static class SpatialSweepAssetBuilder
    {
        [VfxBuilder("SpatialSweep")]
        [MenuItem("Tools/ConfusedGameDev/VFX/Rebuild Riftblade Sweep Assets")]
        public static void Build()
        {
            GameObject root = VfxAssetBuilder.Create<SpatialSweepEffect, SpatialSweepPreset>("SpatialSweep", new[]
            {
                new VfxAssetBuilder.Layer("Refraction", SpatialSweepMeshes.CreateRefraction()),
                new VfxAssetBuilder.Layer("Halo", SpatialSweepMeshes.CreateHalo()),
                new VfxAssetBuilder.Layer("Streaks", SpatialSweepMeshes.CreateStreaks()),
                new VfxAssetBuilder.Layer("Edge", SpatialSweepMeshes.CreateEdge())
            }, out _);
            VfxAssetBuilder.Save(root, "SpatialSweep");
        }
    }
}
