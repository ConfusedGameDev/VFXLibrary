using UnityEditor;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Editor
{
    public static class SpellIndicatorSectorAssetBuilder
    {
        [VfxBuilder("SpellIndicatorSector")]
        [MenuItem("Tools/ConfusedGameDev/VFX/Rebuild Red Sector Spell Indicator Assets")]
        public static void Build()
        {
            GameObject root = VfxAssetBuilder.Create<SpellIndicatorSectorEffect, SpellIndicatorSectorPreset>("SpellIndicatorSector", new[]
            {
                new VfxAssetBuilder.Layer("Surface", SpellIndicatorSectorMeshes.CreateSurface())
            }, out _);
            VfxAssetBuilder.Save(root, "SpellIndicatorSector");
        }
    }
}
