using UnityEditor;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Editor
{
    public static class FrostLanceRainAssetBuilder
    {
        [VfxBuilder("FrostLanceRain")]
        [MenuItem("Tools/ConfusedGameDev/VFX/Rebuild Falling Frost Spear Array Assets")]
        public static void Build()
        {
            GameObject root = VfxAssetBuilder.Create<FrostLanceRainEffect, FrostLanceRainPreset>("FrostLanceRain", new[]
            {
                new VfxAssetBuilder.Layer("Body", FrostLanceRainMeshes.CreateBody()),
                new VfxAssetBuilder.Layer("Particles", FrostLanceRainMeshes.CreateParticles())
            }, out _);
            VfxAssetBuilder.Save(root, "FrostLanceRain");
        }
    }
}
