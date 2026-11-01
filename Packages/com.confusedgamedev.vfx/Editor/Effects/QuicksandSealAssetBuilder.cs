using UnityEditor;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Editor
{
    public static class QuicksandSealAssetBuilder
    {
        [VfxBuilder("QuicksandSeal")]
        [MenuItem("Tools/ConfusedGameDev/VFX/Rebuild Sand-Gathering Sigil Assets")]
        public static void Build()
        {
            GameObject root = VfxAssetBuilder.Create<QuicksandSealEffect, QuicksandSealPreset>("QuicksandSeal", new[]
            {
                new VfxAssetBuilder.Layer("Sigil", QuicksandSealMeshes.CreateSigil()),
                new VfxAssetBuilder.Layer("Body", QuicksandSealMeshes.CreateBody()),
                new VfxAssetBuilder.Layer("Particles", QuicksandSealMeshes.CreateParticles())
            }, out _);
            VfxAssetBuilder.Save(root, "QuicksandSeal");
        }
    }
}
