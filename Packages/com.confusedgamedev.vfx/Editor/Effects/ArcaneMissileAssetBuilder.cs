using UnityEditor;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Editor
{
    public static class ArcaneMissileAssetBuilder
    {
        [VfxBuilder("ArcaneMissile")]
        [MenuItem("Tools/ConfusedGameDev/VFX/Rebuild Runic Crystal Missiles Assets")]
        public static void Build()
        {
            GameObject root = VfxAssetBuilder.Create<ArcaneMissileEffect, ArcaneMissilePreset>("ArcaneMissile", new[]
            {
                new VfxAssetBuilder.Layer("Particles", ArcaneMissileMeshes.CreateParticles()),
                new VfxAssetBuilder.Layer("Gems", ArcaneMissileMeshes.CreateGems()),
                new VfxAssetBuilder.Layer("Trails", ArcaneMissileMeshes.CreateTrails()),
                new VfxAssetBuilder.Layer("Impact", ArcaneMissileMeshes.CreateImpact()),
                new VfxAssetBuilder.Layer("Glow", ArcaneMissileMeshes.CreateGlow())
            }, out Renderer[] renderers);

            VfxAssetBuilder.SaveProjectile<ArcaneMissileEffect>(root, "ArcaneMissile", renderers[3], renderers[4]);
        }
    }
}
