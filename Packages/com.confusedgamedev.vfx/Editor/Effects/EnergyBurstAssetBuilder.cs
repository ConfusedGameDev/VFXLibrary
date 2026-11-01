using UnityEditor;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Editor
{
    public static class EnergyBurstAssetBuilder
    {
        [VfxBuilder("EnergyBurst")]
        [MenuItem("Tools/ConfusedGameDev/VFX/Rebuild Energy Burst Assets")]
        public static void Build()
        {
            GameObject root = VfxAssetBuilder.Create<EnergyBurstEffect, EnergyBurstPreset>("EnergyBurst", new[]
            {
                new VfxAssetBuilder.Layer("Clouds", EnergyBurstMeshes.CreateClouds()),
                new VfxAssetBuilder.Layer("Wave", EnergyBurstMeshes.CreateWave()),
                new VfxAssetBuilder.Layer("Arcs", EnergyBurstMeshes.CreateArcs()),
                new VfxAssetBuilder.Layer("Fragments", EnergyBurstMeshes.CreateFragments()),
                new VfxAssetBuilder.Layer("Sparks", EnergyBurstMeshes.CreateSparks()),
                new VfxAssetBuilder.Layer("Flash", EnergyBurstMeshes.CreateFlash())
            }, out _);
            VfxAssetBuilder.Save(root, "EnergyBurst");
        }
    }
}
