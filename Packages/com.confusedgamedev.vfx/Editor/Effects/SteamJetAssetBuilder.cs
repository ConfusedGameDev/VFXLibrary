using UnityEditor;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Editor
{
    public static class SteamJetAssetBuilder
    {
        [VfxBuilder("SteamJet")]
        [MenuItem("Tools/ConfusedGameDev/VFX/Rebuild Rising Steam Jet Assets")]
        public static void Build()
        {
            GameObject root = VfxAssetBuilder.Create<SteamJetEffect, SteamJetPreset>("SteamJet", new[]
            {
                new VfxAssetBuilder.Layer("Clouds", SteamJetMeshes.CreateClouds())
            }, out _);
            VfxAssetBuilder.Save(root, "SteamJet");
        }
    }
}
