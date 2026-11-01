using UnityEditor;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Editor
{
    public static class WindVortexAssetBuilder
    {
        [VfxBuilder("WindVortex")]
        [MenuItem("Tools/ConfusedGameDev/VFX/Rebuild Leaf-Swept Vortex Assets")]
        public static void Build()
        {
            GameObject root = VfxAssetBuilder.Create<WindVortexEffect, WindVortexPreset>("WindVortex", new[]
            {
                new VfxAssetBuilder.Layer("Ground", WindVortexMeshes.CreateGround()),
                new VfxAssetBuilder.Layer("Dust", WindVortexMeshes.CreateDust()),
                new VfxAssetBuilder.Layer("Column", WindVortexMeshes.CreateColumn()),
                new VfxAssetBuilder.Layer("Particles", WindVortexMeshes.CreateParticles()),
                new VfxAssetBuilder.Layer("Debris", WindVortexMeshes.CreateDebris())
            }, out _);
            VfxAssetBuilder.Save(root, "WindVortex");
        }
    }
}
