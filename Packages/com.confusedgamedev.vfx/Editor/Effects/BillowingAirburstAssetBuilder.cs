using UnityEditor;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Editor
{
    public static class BillowingAirburstAssetBuilder
    {
        [VfxBuilder("BillowingAirburst")]
        [MenuItem("Tools/ConfusedGameDev/VFX/Rebuild Billowing Airburst Assets")]
        public static void Build()
        {
            GameObject root = VfxAssetBuilder.Create<BillowingAirburstEffect, BillowingAirburstPreset>("BillowingAirburst", new[]
            {
                new VfxAssetBuilder.Layer("Glow", BillowingAirburstMeshes.CreateGlow()),
                new VfxAssetBuilder.Layer("Core", BillowingAirburstMeshes.CreateCore()),
                new VfxAssetBuilder.Layer("Jets", BillowingAirburstMeshes.CreateJets()),
                new VfxAssetBuilder.Layer("Wave", BillowingAirburstMeshes.CreateWave()),
                new VfxAssetBuilder.Layer("Arcs", BillowingAirburstMeshes.CreateArcs()),
                new VfxAssetBuilder.Layer("Flash", BillowingAirburstMeshes.CreateFlash()),
                new VfxAssetBuilder.Layer("Embers", BillowingAirburstMeshes.CreateEmbers())
            }, out _);
            VfxAssetBuilder.Save(root, "BillowingAirburst");
        }
    }
}
