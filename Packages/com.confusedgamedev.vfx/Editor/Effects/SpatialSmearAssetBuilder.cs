using UnityEditor;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Editor
{
    public static class SpatialSmearAssetBuilder
    {
        [VfxBuilder("SpatialSmear")]
        [MenuItem("Tools/ConfusedGameDev/VFX/Rebuild Riftblade Trail Assets")]
        public static void Build()
        {
            GameObject root = VfxAssetBuilder.Create<SpatialSmearEffect, SpatialSmearPreset>("SpatialSmear", new[]
            {
                new VfxAssetBuilder.Layer("Refraction", SpatialSmearMeshes.CreateRefraction()),
                new VfxAssetBuilder.Layer("Halo", SpatialSmearMeshes.CreateHalo()),
                new VfxAssetBuilder.Layer("Edge", SpatialSmearMeshes.CreateEdge())
            }, out _);
            VfxAssetBuilder.Save(root, "SpatialSmear");
        }
    }
}
