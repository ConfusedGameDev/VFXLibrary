using UnityEditor;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Editor
{
    public static class SpiralGaleAssetBuilder
    {
        [VfxBuilder("SpiralGale")]
        [MenuItem("Tools/ConfusedGameDev/VFX/Rebuild Spiraling Wind Spear Assets")]
        public static void Build()
        {
            GameObject root = VfxAssetBuilder.Create<SpiralGaleEffect, SpiralGalePreset>("SpiralGale", new[]
            {
                new VfxAssetBuilder.Layer("Trail", SpiralGaleMeshes.CreateTrail()),
                new VfxAssetBuilder.Layer("Body", SpiralGaleMeshes.CreateBody()),
                new VfxAssetBuilder.Layer("Particles", SpiralGaleMeshes.CreateParticles()),
                new VfxAssetBuilder.Layer("Impact", SpiralGaleMeshes.CreateImpact()),
                new VfxAssetBuilder.Layer("Glow", SpiralGaleMeshes.CreateGlow())
            }, out Renderer[] renderers);

            VfxAssetBuilder.SaveProjectile<SpiralGaleEffect>(root, "SpiralGale", renderers[3], renderers[4]);
        }
    }
}
