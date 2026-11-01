using UnityEditor;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Editor
{
    public static class AstralConvergenceAssetBuilder
    {
        [VfxBuilder("AstralConvergence")]
        [MenuItem("Tools/ConfusedGameDev/VFX/Rebuild Astral Ring Detonation Assets")]
        public static void Build()
        {
            GameObject root = VfxAssetBuilder.Create<AstralConvergenceEffect, AstralConvergencePreset>("AstralConvergence", new[]
            {
                new VfxAssetBuilder.Layer("Body", AstralConvergenceMeshes.CreateBody()),
                new VfxAssetBuilder.Layer("Particles", AstralConvergenceMeshes.CreateParticles())
            }, out _);
            VfxAssetBuilder.Save(root, "AstralConvergence");
        }
    }
}
