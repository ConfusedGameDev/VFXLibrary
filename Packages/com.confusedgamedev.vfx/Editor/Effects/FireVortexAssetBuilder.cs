using UnityEditor;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Editor
{
    public static class FireVortexAssetBuilder
    {
        [VfxBuilder("FireVortex")]
        [MenuItem("Tools/ConfusedGameDev/VFX/Rebuild Flame-Swept Vortex Assets")]
        public static void Build()
        {
            GameObject root = VfxAssetBuilder.Create<FireVortexEffect, FireVortexPreset>("FireVortex", new[]
            {
                new VfxAssetBuilder.Layer("Ground", FireVortexMeshes.CreateGround()),
                new VfxAssetBuilder.Layer("Dust", FireVortexMeshes.CreateDust()),
                new VfxAssetBuilder.Layer("Column", FireVortexMeshes.CreateColumn()),
                new VfxAssetBuilder.Layer("Particles", FireVortexMeshes.CreateParticles()),
                new VfxAssetBuilder.Layer("Debris", FireVortexMeshes.CreateDebris())
            }, out _);
            VfxAssetBuilder.Save(root, "FireVortex");
        }
    }
}
