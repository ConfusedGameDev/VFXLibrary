using UnityEditor;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Editor
{
    public static class RevivalBloomAssetBuilder
    {
        [VfxBuilder("RevivalBloom")]
        [MenuItem("Tools/ConfusedGameDev/VFX/Rebuild Vitality Blossom Assets")]
        public static void Build()
        {
            GameObject root = VfxAssetBuilder.Create<RevivalBloomEffect, RevivalBloomPreset>("RevivalBloom", new[]
            {
                new VfxAssetBuilder.Layer("Body", RevivalBloomMeshes.CreateBody()),
                new VfxAssetBuilder.Layer("Particles", RevivalBloomMeshes.CreateParticles())
            }, out _);
            VfxAssetBuilder.Save(root, "RevivalBloom");
        }
    }
}
