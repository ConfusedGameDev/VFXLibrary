using UnityEditor;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Editor
{
    public static class ThornCrownAssetBuilder
    {
        [VfxBuilder("ThornCrown")]
        [MenuItem("Tools/ConfusedGameDev/VFX/Rebuild Thornvine Blossom Crown Assets")]
        public static void Build()
        {
            GameObject root = VfxAssetBuilder.Create<ThornCrownEffect, ThornCrownPreset>("ThornCrown", new[]
            {
                new VfxAssetBuilder.Layer("Sigil", ThornCrownMeshes.CreateSigil()),
                new VfxAssetBuilder.Layer("Body", ThornCrownMeshes.CreateBody()),
                new VfxAssetBuilder.Layer("Particles", ThornCrownMeshes.CreateParticles())
            }, out _);
            VfxAssetBuilder.Save(root, "ThornCrown");
        }
    }
}
