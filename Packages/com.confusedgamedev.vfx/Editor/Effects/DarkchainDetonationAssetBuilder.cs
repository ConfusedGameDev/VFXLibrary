using UnityEditor;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Editor
{
    public static class DarkchainDetonationAssetBuilder
    {
        [VfxBuilder("DarkchainDetonation")]
        [MenuItem("Tools/ConfusedGameDev/VFX/Rebuild Darkchain Sigil Rupture Assets")]
        public static void Build()
        {
            GameObject root = VfxAssetBuilder.Create<DarkchainDetonationEffect, DarkchainDetonationPreset>("DarkchainDetonation", new[]
            {
                new VfxAssetBuilder.Layer("Sigil0", DarkchainDetonationMeshes.CreateSigil0()),
                new VfxAssetBuilder.Layer("Sigil1", DarkchainDetonationMeshes.CreateSigil1()),
                new VfxAssetBuilder.Layer("ChainBody", DarkchainDetonationMeshes.CreateChainBody()),
                new VfxAssetBuilder.Layer("ChainGlow", DarkchainDetonationMeshes.CreateChainGlow()),
                new VfxAssetBuilder.Layer("RootSeals", DarkchainDetonationMeshes.CreateRootSeals()),
                new VfxAssetBuilder.Layer("OrbBody", DarkchainDetonationMeshes.CreateOrbBody()),
                new VfxAssetBuilder.Layer("OrbHalo", DarkchainDetonationMeshes.CreateOrbHalo()),
                new VfxAssetBuilder.Layer("OrbArcs", DarkchainDetonationMeshes.CreateOrbArcs()),
                new VfxAssetBuilder.Layer("FieldLightning", DarkchainDetonationMeshes.CreateFieldLightning()),
                new VfxAssetBuilder.Layer("BlackAura", DarkchainDetonationMeshes.CreateBlackAura()),
                new VfxAssetBuilder.Layer("InwardRibbons", DarkchainDetonationMeshes.CreateInwardRibbons()),
                new VfxAssetBuilder.Layer("InwardParticles", DarkchainDetonationMeshes.CreateInwardParticles()),
                new VfxAssetBuilder.Layer("Debris", DarkchainDetonationMeshes.CreateDebris()),
                new VfxAssetBuilder.Layer("BlastInk", DarkchainDetonationMeshes.CreateBlastInk()),
                new VfxAssetBuilder.Layer("Blast", DarkchainDetonationMeshes.CreateBlast()),
                new VfxAssetBuilder.Layer("EnergySurface", DarkchainDetonationMeshes.CreateEnergySurface()),
                new VfxAssetBuilder.Layer("EnergyGlow", DarkchainDetonationMeshes.CreateEnergyGlow()),
                new VfxAssetBuilder.Layer("CoreEjection", DarkchainDetonationMeshes.CreateCoreEjection()),
                new VfxAssetBuilder.Layer("ReleasePlasma", DarkchainDetonationMeshes.CreateReleasePlasma()),
                new VfxAssetBuilder.Layer("ImpactGlints", DarkchainDetonationMeshes.CreateImpactGlints()),
                new VfxAssetBuilder.Layer("AfterSmoke", DarkchainDetonationMeshes.CreateAfterSmoke()),
                new VfxAssetBuilder.Layer("Refraction", DarkchainDetonationMeshes.CreateRefraction()),
                new VfxAssetBuilder.Layer("ShockRing", DarkchainDetonationMeshes.CreateShockRing()),
                new VfxAssetBuilder.Layer("GroundSmoke", DarkchainDetonationMeshes.CreateGroundSmoke()),
                new VfxAssetBuilder.Layer("SmokeTails", DarkchainDetonationMeshes.CreateSmokeTails())
            }, out _);
            VfxAssetBuilder.Save(root, "DarkchainDetonation");
        }
    }
}
