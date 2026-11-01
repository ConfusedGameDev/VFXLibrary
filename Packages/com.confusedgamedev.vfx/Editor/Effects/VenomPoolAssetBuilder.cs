using UnityEditor;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Editor
{
    public static class VenomPoolAssetBuilder
    {
        [VfxBuilder("VenomPool")]
        [MenuItem("Tools/ConfusedGameDev/VFX/Rebuild Bubbling Venom Sigil Assets")]
        public static void Build()
        {
            GameObject root = VfxAssetBuilder.Create<VenomPoolEffect, VenomPoolPreset>("VenomPool", new[]
            {
                new VfxAssetBuilder.Layer("Sigil", VenomPoolMeshes.CreateSigil()),
                new VfxAssetBuilder.Layer("Body", VenomPoolMeshes.CreateBody()),
                new VfxAssetBuilder.Layer("Particles", VenomPoolMeshes.CreateParticles()),
                new VfxAssetBuilder.Layer("Mist", VenomPoolMeshes.CreateMist())
            }, out _);
            VfxAssetBuilder.Save(root, "VenomPool");
        }
    }
}
