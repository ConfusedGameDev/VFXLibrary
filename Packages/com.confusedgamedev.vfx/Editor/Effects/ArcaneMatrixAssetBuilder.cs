using UnityEditor;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Editor
{
    public static class ArcaneMatrixAssetBuilder
    {
        [VfxBuilder("ArcaneMatrix")]
        [MenuItem("Tools/ConfusedGameDev/VFX/Rebuild Floating Rune Matrix Assets")]
        public static void Build()
        {
            GameObject root = VfxAssetBuilder.Create<ArcaneMatrixEffect, ArcaneMatrixPreset>("ArcaneMatrix", new[]
            {
                new VfxAssetBuilder.Layer("Sigil", ArcaneMatrixMeshes.CreateSigil()),
                new VfxAssetBuilder.Layer("Body", ArcaneMatrixMeshes.CreateBody()),
                new VfxAssetBuilder.Layer("Particles", ArcaneMatrixMeshes.CreateParticles())
            }, out _);
            VfxAssetBuilder.Save(root, "ArcaneMatrix");
        }
    }
}
