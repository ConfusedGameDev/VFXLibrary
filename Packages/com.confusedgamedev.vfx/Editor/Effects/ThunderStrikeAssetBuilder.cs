using UnityEditor;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Editor
{
    public static class ThunderStrikeAssetBuilder
    {
        [VfxBuilder("ThunderStrike")]
        [MenuItem("Tools/ConfusedGameDev/VFX/Rebuild Vortex Lightning Strike Assets")]
        public static void Build()
        {
            GameObject root = VfxAssetBuilder.Create<ThunderStrikeEffect, ThunderStrikePreset>("ThunderStrike", new[]
            {
                new VfxAssetBuilder.Layer("Body", ThunderStrikeMeshes.CreateBody()),
                new VfxAssetBuilder.Layer("Particles", ThunderStrikeMeshes.CreateParticles())
            }, out _);
            VfxAssetBuilder.Save(root, "ThunderStrike");
        }
    }
}
