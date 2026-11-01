using UnityEditor;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Editor
{
    public static class SacredRelicDescentAssetBuilder
    {
        [VfxBuilder("SacredRelicDescent")]
        [MenuItem("Tools/ConfusedGameDev/VFX/Rebuild Sacred Relic Descent Assets")]
        public static void Build()
        {
            GameObject root = VfxAssetBuilder.Create<SacredRelicDescentEffect, SacredRelicDescentPreset>("SacredRelicDescent", new[]
            {
                new VfxAssetBuilder.Layer("Cracks", SacredRelicDescentMeshes.CreateCracks()),
                new VfxAssetBuilder.Layer("Sigil", SacredRelicDescentMeshes.CreateSigil()),
                new VfxAssetBuilder.Layer("Impact", SacredRelicDescentMeshes.CreateImpact()),
                new VfxAssetBuilder.Layer("Echo", SacredRelicDescentMeshes.CreateEcho()),
                new VfxAssetBuilder.Layer("Wave", SacredRelicDescentMeshes.CreateWave()),
                new VfxAssetBuilder.Layer("Debris", SacredRelicDescentMeshes.CreateDebris()),
                new VfxAssetBuilder.Layer("Dust", SacredRelicDescentMeshes.CreateDust()),
                new VfxAssetBuilder.Layer("Relic", SacredRelicDescentMeshes.CreateRelic()),
                new VfxAssetBuilder.Layer("Trail", SacredRelicDescentMeshes.CreateTrail()),
                new VfxAssetBuilder.Layer("Smoke", SacredRelicDescentMeshes.CreateSmoke()),
                new VfxAssetBuilder.Layer("Motes", SacredRelicDescentMeshes.CreateMotes())
            }, out _);
            VfxAssetBuilder.Save(root, "SacredRelicDescent");
        }
    }
}
