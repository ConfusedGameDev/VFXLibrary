using UnityEditor;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Editor
{
    public static class ArcRayAssetBuilder
    {
        [VfxBuilder("ArcRay")]
        [MenuItem("Tools/ConfusedGameDev/VFX/Rebuild Forked Lightning Stream Assets")]
        public static void Build()
        {
            GameObject root = VfxAssetBuilder.Create<ArcRayEffect, ArcRayPreset>("ArcRay", new[]
            {
                new VfxAssetBuilder.Layer("Corona", ArcRayMeshes.CreateCorona()),
                new VfxAssetBuilder.Layer("Lightning", ArcRayMeshes.CreateLightning()),
                new VfxAssetBuilder.Layer("Particles", ArcRayMeshes.CreateParticles()),
                new VfxAssetBuilder.Layer("Flares", ArcRayMeshes.CreateFlares())
            }, out _);

            VfxAssetBuilder.SaveBeam<ArcRayEffect>(root, "ArcRay");
        }
    }
}
