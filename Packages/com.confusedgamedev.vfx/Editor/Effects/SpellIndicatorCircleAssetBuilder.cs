using UnityEditor;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Editor
{
    public static class SpellIndicatorCircleAssetBuilder
    {
        [VfxBuilder("SpellIndicatorCircle")]
        [MenuItem("Tools/ConfusedGameDev/VFX/Rebuild Red Circle Spell Indicator Assets")]
        public static void Build()
        {
            GameObject root = VfxAssetBuilder.Create<SpellIndicatorCircleEffect, SpellIndicatorCirclePreset>("SpellIndicatorCircle", new[]
            {
                new VfxAssetBuilder.Layer("Surface", SpellIndicatorCircleMeshes.CreateSurface())
            }, out _);
            VfxAssetBuilder.Save(root, "SpellIndicatorCircle");
        }
    }
}
