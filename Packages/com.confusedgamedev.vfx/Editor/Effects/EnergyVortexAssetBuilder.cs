using UnityEditor;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Editor
{
    public static class EnergyVortexAssetBuilder
    {
        [VfxBuilder("EnergyVortex")]
        [MenuItem("Tools/ConfusedGameDev/VFX/Rebuild Runic Ring Vortex Assets")]
        public static void Build()
        {
            GameObject root = VfxAssetBuilder.Create<EnergyVortexEffect, EnergyVortexPreset>("EnergyVortex", new[]
            {
                new VfxAssetBuilder.Layer("Ground", EnergyVortexMeshes.CreateGround()),
                new VfxAssetBuilder.Layer("Dust", EnergyVortexMeshes.CreateDust()),
                new VfxAssetBuilder.Layer("Column", EnergyVortexMeshes.CreateColumn()),
                new VfxAssetBuilder.Layer("Particles", EnergyVortexMeshes.CreateParticles()),
                new VfxAssetBuilder.Layer("Debris", EnergyVortexMeshes.CreateDebris())
            }, out _);
            VfxAssetBuilder.Save(root, "EnergyVortex");
        }
    }
}
