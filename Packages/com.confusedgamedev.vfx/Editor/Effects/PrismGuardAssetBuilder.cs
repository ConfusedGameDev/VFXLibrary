using UnityEditor;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Editor
{
    public static class PrismGuardAssetBuilder
    {
        [VfxBuilder("PrismGuard")]
        [MenuItem("Tools/ConfusedGameDev/VFX/Rebuild Prismatic Crystal Bulwark Assets")]
        public static void Build()
        {
            GameObject root = VfxAssetBuilder.Create<PrismGuardEffect, PrismGuardPreset>("PrismGuard", new[]
            {
                new VfxAssetBuilder.Layer("Body", PrismGuardMeshes.CreateBody()),
                new VfxAssetBuilder.Layer("Particles", PrismGuardMeshes.CreateParticles())
            }, out _);
            VfxAssetBuilder.Save(root, "PrismGuard");
        }
    }
}
