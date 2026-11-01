using UnityEditor;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Editor
{
    public static class ElectricMagicArrowStrikeAssetBuilder
    {
        [VfxBuilder("ElectricMagicArrowStrike")]
        [MenuItem("Tools/ConfusedGameDev/VFX/Rebuild Golden-Bladed Lightning Arrow Assets")]
        public static void Build()
        {
            GameObject root = VfxAssetBuilder.Create<ElectricMagicArrowStrikeEffect, ElectricMagicArrowStrikePreset>("ElectricMagicArrowStrike", new[]
            {
                new VfxAssetBuilder.Layer("Core", ElectricMagicArrowStrikeMeshes.CreateCore()),
                new VfxAssetBuilder.Layer("Halo", ElectricMagicArrowStrikeMeshes.CreateHalo()),
                new VfxAssetBuilder.Layer("Arcs", ElectricMagicArrowStrikeMeshes.CreateArcs()),
                new VfxAssetBuilder.Layer("Sigil", ElectricMagicArrowStrikeMeshes.CreateSigil()),
                new VfxAssetBuilder.Layer("Trails", ElectricMagicArrowStrikeMeshes.CreateTrails()),
                new VfxAssetBuilder.Layer("Impact", ElectricMagicArrowStrikeMeshes.CreateImpact()),
                new VfxAssetBuilder.Layer("Glow", ElectricMagicArrowStrikeMeshes.CreateGlow()),
                new VfxAssetBuilder.Layer("Particles", ElectricMagicArrowStrikeMeshes.CreateParticles())
            }, out Renderer[] renderers);

            VfxAssetBuilder.SaveProjectile<ElectricMagicArrowStrikeEffect>(root, "ElectricMagicArrowStrike", renderers[5], renderers[6]);
        }
    }
}
