using UnityEditor;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Editor
{
    public static class PlasmaBoltAssetBuilder
    {
        [VfxBuilder("PlasmaBolt")]
        [MenuItem("Tools/ConfusedGameDev/VFX/Rebuild Plasma Dart Assets")]
        public static void Build()
        {
            GameObject root = VfxAssetBuilder.Create<PlasmaBoltEffect, PlasmaBoltPreset>("PlasmaBolt", new[]
            {
                new VfxAssetBuilder.Layer("Particles", PlasmaBoltMeshes.CreateParticles()),
                new VfxAssetBuilder.Layer("Halo", PlasmaBoltMeshes.CreateHalo()),
                new VfxAssetBuilder.Layer("Core", PlasmaBoltMeshes.CreateCore()),
                new VfxAssetBuilder.Layer("Trails", PlasmaBoltMeshes.CreateTrails()),
                new VfxAssetBuilder.Layer("Envelope", PlasmaBoltMeshes.CreateEnvelope()),
                new VfxAssetBuilder.Layer("Impact", PlasmaBoltMeshes.CreateImpact()),
                new VfxAssetBuilder.Layer("Glow", PlasmaBoltMeshes.CreateGlow())
            }, out Renderer[] renderers);

            VfxAssetBuilder.SaveProjectile<PlasmaBoltEffect>(root, "PlasmaBolt", renderers[5], renderers[6]);
        }
    }
}
