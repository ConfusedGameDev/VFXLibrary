using UnityEditor;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Editor
{
    public static class BlackHoleAssetBuilder
    {
        [VfxBuilder("BlackHole")]
        [MenuItem("Tools/ConfusedGameDev/VFX/Rebuild Luminous Vortex Black Hole Assets")]
        public static void Build()
        {
            GameObject root = VfxAssetBuilder.Create<BlackHoleEffect, BlackHolePreset>("BlackHole", new[]
            {
                new VfxAssetBuilder.Layer("RearDisk", BlackHoleMeshes.CreateRearDisk()),
                new VfxAssetBuilder.Layer("OuterLens", BlackHoleMeshes.CreateOuterLens()),
                new VfxAssetBuilder.Layer("Lens", BlackHoleMeshes.CreateLens()),
                new VfxAssetBuilder.Layer("FrontDisk", BlackHoleMeshes.CreateFrontDisk()),
                new VfxAssetBuilder.Layer("Infall", BlackHoleMeshes.CreateInfall())
            }, out _);
            VfxAssetBuilder.Save(root, "BlackHole");
        }
    }
}
