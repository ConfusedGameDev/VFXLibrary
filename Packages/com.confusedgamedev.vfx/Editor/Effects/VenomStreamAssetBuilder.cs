using UnityEditor;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Editor
{
    public static class VenomStreamAssetBuilder
    {
        [VfxBuilder("VenomStream")]
        [MenuItem("Tools/ConfusedGameDev/VFX/Rebuild Corrosive Venom Jet Assets")]
        public static void Build()
        {
            GameObject root = VfxAssetBuilder.Create<VenomStreamEffect, VenomStreamPreset>("VenomStream", new[]
            {
                new VfxAssetBuilder.Layer("Body", VenomStreamMeshes.CreateBody()),
                new VfxAssetBuilder.Layer("Droplets", VenomStreamMeshes.CreateDroplets())
            }, out _);

            VfxAssetBuilder.Save(root, "VenomStream");
        }
    }
}
