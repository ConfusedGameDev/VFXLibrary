using UnityEditor;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Editor
{
    public static class FrostFieldAssetBuilder
    {
        [VfxBuilder("FrostField")]
        [MenuItem("Tools/ConfusedGameDev/VFX/Rebuild Sixfold Frost Sigil Assets")]
        public static void Build()
        {
            GameObject root = VfxAssetBuilder.Create<FrostFieldEffect, FrostFieldPreset>("FrostField", new[]
            {
                new VfxAssetBuilder.Layer("Aura", FrostFieldMeshes.CreateAura()),
                new VfxAssetBuilder.Layer("Sigil", FrostFieldMeshes.CreateSigil()),
                new VfxAssetBuilder.Layer("Particles", FrostFieldMeshes.CreateParticles())
            }, out _);
            VfxAssetBuilder.Save(root, "FrostField");
        }
    }
}
