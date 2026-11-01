using UnityEditor;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Editor
{
    public static class FlameSurgeAssetBuilder
    {
        [VfxBuilder("FlameSurge")]
        [MenuItem("Tools/ConfusedGameDev/VFX/Rebuild Surging Flame Tide Assets")]
        public static void Build()
        {
            GameObject root = VfxAssetBuilder.Create<FlameSurgeEffect, FlameSurgePreset>("FlameSurge", new[]
            {
                new VfxAssetBuilder.Layer("Body", FlameSurgeMeshes.CreateBody()),
                new VfxAssetBuilder.Layer("Particles", FlameSurgeMeshes.CreateParticles())
            }, out _);
            VfxAssetBuilder.Save(root, "FlameSurge");
        }
    }
}
