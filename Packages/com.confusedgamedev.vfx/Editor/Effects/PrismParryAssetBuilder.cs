using UnityEditor;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Editor
{
    public static class PrismParryAssetBuilder
    {
        [VfxBuilder("PrismParry")]
        [MenuItem("Tools/ConfusedGameDev/VFX/Rebuild Prismatic Crystal Block Assets")]
        public static void Build()
        {
            GameObject root = VfxAssetBuilder.Create<PrismParryEffect, PrismParryPreset>("PrismParry", new[]
            {
                new VfxAssetBuilder.Layer("Body", PrismParryMeshes.CreateBody()),
                new VfxAssetBuilder.Layer("Particles", PrismParryMeshes.CreateParticles())
            }, out _);
            VfxAssetBuilder.Save(root, "PrismParry");
        }
    }
}
