using UnityEditor;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Editor
{
    public static class MagmaFissureAssetBuilder
    {
        [VfxBuilder("MagmaFissure")]
        [MenuItem("Tools/ConfusedGameDev/VFX/Rebuild Molten Vein Fissure Assets")]
        public static void Build()
        {
            GameObject root = VfxAssetBuilder.Create<MagmaFissureEffect, MagmaFissurePreset>("MagmaFissure", new[]
            {
                new VfxAssetBuilder.Layer("Body", MagmaFissureMeshes.CreateBody()),
                new VfxAssetBuilder.Layer("Particles", MagmaFissureMeshes.CreateParticles())
            }, out _);
            VfxAssetBuilder.Save(root, "MagmaFissure");
        }
    }
}
