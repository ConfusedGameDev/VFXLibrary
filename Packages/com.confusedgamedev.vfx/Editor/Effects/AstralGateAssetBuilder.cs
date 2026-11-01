using UnityEditor;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Editor
{
    public static class AstralGateAssetBuilder
    {
        [VfxBuilder("AstralGate")]
        [MenuItem("Tools/ConfusedGameDev/VFX/Rebuild Gate of Astral Tracery Assets")]
        public static void Build()
        {
            GameObject root = VfxAssetBuilder.Create<AstralGateEffect, AstralGatePreset>("AstralGate", new[]
            {
                new VfxAssetBuilder.Layer("Frame", AstralGateMeshes.CreateFrame()),
                new VfxAssetBuilder.Layer("Membrane", AstralGateMeshes.CreateMembrane()),
                new VfxAssetBuilder.Layer("Particles", AstralGateMeshes.CreateParticles())
            }, out _);
            VfxAssetBuilder.Save(root, "AstralGate");
        }
    }
}
