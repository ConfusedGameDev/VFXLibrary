using UnityEditor;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Editor
{
    public static class ShadowGlaiveAssetBuilder
    {
        [VfxBuilder("ShadowGlaive")]
        [MenuItem("Tools/ConfusedGameDev/VFX/Rebuild Afterimage Glaive Assets")]
        public static void Build()
        {
            GameObject root = VfxAssetBuilder.Create<ShadowGlaiveEffect, ShadowGlaivePreset>("ShadowGlaive", new[]
            {
                new VfxAssetBuilder.Layer("Trail", ShadowGlaiveMeshes.CreateTrail()),
                new VfxAssetBuilder.Layer("Body", ShadowGlaiveMeshes.CreateBody()),
                new VfxAssetBuilder.Layer("Particles", ShadowGlaiveMeshes.CreateParticles()),
                new VfxAssetBuilder.Layer("Impact", ShadowGlaiveMeshes.CreateImpact()),
                new VfxAssetBuilder.Layer("Glow", ShadowGlaiveMeshes.CreateGlow())
            }, out Renderer[] renderers);

            VfxAssetBuilder.SaveProjectile<ShadowGlaiveEffect>(root, "ShadowGlaive", renderers[3], renderers[4]);
        }
    }
}
