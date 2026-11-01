using UnityEditor;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Editor
{
    public static class DustDevilAssetBuilder
    {
        [VfxBuilder("DustDevil")]
        [MenuItem("Tools/ConfusedGameDev/VFX/Rebuild Sand-Swept Vortex Assets")]
        public static void Build()
        {
            GameObject root = VfxAssetBuilder.Create<DustDevilEffect, DustDevilPreset>("DustDevil", new[]
            {
                new VfxAssetBuilder.Layer("Ground", DustDevilMeshes.CreateGround()),
                new VfxAssetBuilder.Layer("Dust", DustDevilMeshes.CreateDust()),
                new VfxAssetBuilder.Layer("Column", DustDevilMeshes.CreateColumn()),
                new VfxAssetBuilder.Layer("Particles", DustDevilMeshes.CreateParticles()),
                new VfxAssetBuilder.Layer("Debris", DustDevilMeshes.CreateDebris())
            }, out _);
            VfxAssetBuilder.Save(root, "DustDevil");
        }
    }
}
