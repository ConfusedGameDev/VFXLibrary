using UnityEditor;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Editor
{
    public static class PainterlyGrassAssetBuilder
    {
        [VfxBuilder("PainterlyGrass")]
        [MenuItem("Tools/ConfusedGameDev/VFX/Rebuild Windswept Meadow Assets")]
        public static void Build()
        {
            GameObject root = VfxAssetBuilder.Create<PainterlyGrassEffect, PainterlyGrassPreset>("PainterlyGrass", new[]
            {
                new VfxAssetBuilder.Layer("Blades", PainterlyGrassMeshes.CreateBlades()),
                new VfxAssetBuilder.Layer("Flowers", PainterlyGrassMeshes.CreateFlowers())
            }, out _);
            VfxAssetBuilder.Save(root, "PainterlyGrass");
        }
    }
}
