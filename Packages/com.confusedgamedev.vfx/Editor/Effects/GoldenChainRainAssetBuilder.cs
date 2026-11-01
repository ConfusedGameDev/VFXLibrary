using UnityEditor;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Editor
{
    public static class GoldenChainRainAssetBuilder
    {
        [VfxBuilder("GoldenChainRain")]
        [MenuItem("Tools/ConfusedGameDev/VFX/Rebuild Golden Chain Rain Assets")]
        public static void Build()
        {
            GameObject root = VfxAssetBuilder.Create<GoldenChainRainEffect, GoldenChainRainPreset>("GoldenChainRain", new[]
            {
                new VfxAssetBuilder.Layer("CrackGlow", GoldenChainRainMeshes.CreateCrackGlow()),
                new VfxAssetBuilder.Layer("Cracks", GoldenChainRainMeshes.CreateCracks()),
                new VfxAssetBuilder.Layer("Body", GoldenChainRainMeshes.CreateBody()),
                new VfxAssetBuilder.Layer("Arrowheads", GoldenChainRainMeshes.CreateArrowheads()),
                new VfxAssetBuilder.Layer("Ripples", GoldenChainRainMeshes.CreateRipples()),
                new VfxAssetBuilder.Layer("Halo", GoldenChainRainMeshes.CreateHalo()),
                new VfxAssetBuilder.Layer("Feather", GoldenChainRainMeshes.CreateFeather()),
                new VfxAssetBuilder.Layer("Bloom", GoldenChainRainMeshes.CreateBloom()),
                new VfxAssetBuilder.Layer("Motes", GoldenChainRainMeshes.CreateMotes()),
                new VfxAssetBuilder.Layer("Chips", GoldenChainRainMeshes.CreateChips())
            }, out _);
            VfxAssetBuilder.Save(root, "GoldenChainRain");
        }
    }
}
