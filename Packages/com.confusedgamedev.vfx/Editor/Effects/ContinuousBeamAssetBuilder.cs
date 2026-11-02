using UnityEditor;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Editor
{
    public static class ContinuousBeamAssetBuilder
    {
        [VfxBuilder("ContinuousBeam")]
        [MenuItem("Tools/ConfusedGameDev/VFX/Rebuild Threadwoven Beam Assets")]
        public static void Build()
        {
            GameObject root = VfxAssetBuilder.Create<ContinuousBeamEffect, ContinuousBeamPreset>("ContinuousBeam", new[]
            {
                new VfxAssetBuilder.Layer("Sheath", ContinuousBeamMeshes.CreateSheath()),
                new VfxAssetBuilder.Layer("Body", ContinuousBeamMeshes.CreateBody()),
                new VfxAssetBuilder.Layer("Discs", ContinuousBeamMeshes.CreateDiscs()),
                new VfxAssetBuilder.Layer("Particles", ContinuousBeamMeshes.CreateParticles()),
                new VfxAssetBuilder.Layer("Flares", ContinuousBeamMeshes.CreateFlares())
            }, out _);

            VfxAssetBuilder.SaveBeam<ContinuousBeamEffect>(root, "ContinuousBeam");
        }
    }
}
