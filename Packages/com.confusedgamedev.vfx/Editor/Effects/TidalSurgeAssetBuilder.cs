using UnityEditor;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Editor
{
    public static class TidalSurgeAssetBuilder
    {
        [VfxBuilder("TidalSurge")]
        [MenuItem("Tools/ConfusedGameDev/VFX/Rebuild Breaking Tidal Surge Assets")]
        public static void Build()
        {
            GameObject root = VfxAssetBuilder.Create<TidalSurgeEffect, TidalSurgePreset>("TidalSurge", new[]
            {
                new VfxAssetBuilder.Layer("Body", TidalSurgeMeshes.CreateBody()),
                new VfxAssetBuilder.Layer("Particles", TidalSurgeMeshes.CreateParticles())
            }, out _);
            VfxAssetBuilder.Save(root, "TidalSurge");
        }
    }
}
