using UnityEditor;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Editor
{
    public static class FrostWheelAssetBuilder
    {
        [VfxBuilder("FrostWheel")]
        [MenuItem("Tools/ConfusedGameDev/VFX/Rebuild Crystal-Toothed Ice Wheel Assets")]
        public static void Build()
        {
            GameObject root = VfxAssetBuilder.Create<FrostWheelEffect, FrostWheelPreset>("FrostWheel", new[]
            {
                new VfxAssetBuilder.Layer("Trail", FrostWheelMeshes.CreateTrail()),
                new VfxAssetBuilder.Layer("Body", FrostWheelMeshes.CreateBody()),
                new VfxAssetBuilder.Layer("Particles", FrostWheelMeshes.CreateParticles()),
                new VfxAssetBuilder.Layer("Impact", FrostWheelMeshes.CreateImpact()),
                new VfxAssetBuilder.Layer("Glow", FrostWheelMeshes.CreateGlow())
            }, out Renderer[] renderers);

            VfxAssetBuilder.SaveProjectile<FrostWheelEffect>(root, "FrostWheel", renderers[3], renderers[4]);
        }
    }
}
