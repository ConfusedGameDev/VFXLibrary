using UnityEditor;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Editor
{
    public static class PulseBeamAssetBuilder
    {
        [VfxBuilder("PulseBeam")]
        [MenuItem("Tools/ConfusedGameDev/VFX/Rebuild Ringpulse Ray Assets")]
        public static void Build()
        {
            GameObject root = VfxAssetBuilder.Create<PulseBeamEffect, PulseBeamPreset>("PulseBeam", new[]
            {
                new VfxAssetBuilder.Layer("Body", PulseBeamMeshes.CreateBody()),
                new VfxAssetBuilder.Layer("Discs", PulseBeamMeshes.CreateDiscs()),
                new VfxAssetBuilder.Layer("Particles", PulseBeamMeshes.CreateParticles()),
                new VfxAssetBuilder.Layer("Rings", PulseBeamMeshes.CreateRings()),
                new VfxAssetBuilder.Layer("Flares", PulseBeamMeshes.CreateFlares())
            }, out _);

            VfxAssetBuilder.SaveBeam<PulseBeamEffect>(root, "PulseBeam");
        }
    }
}
