using UnityEditor;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Editor
{
    public static class RadiantBeamAssetBuilder
    {
        [VfxBuilder("RadiantBeam")]
        [MenuItem("Tools/ConfusedGameDev/VFX/Rebuild Solar Halo Beam Assets")]
        public static void Build()
        {
            GameObject root = VfxAssetBuilder.Create<RadiantBeamEffect, RadiantBeamPreset>("RadiantBeam", new[]
            {
                new VfxAssetBuilder.Layer("Body", RadiantBeamMeshes.CreateBody()),
                new VfxAssetBuilder.Layer("Particles", RadiantBeamMeshes.CreateParticles())
            }, out _);

            VfxAssetBuilder.SaveBeam<RadiantBeamEffect>(root, "RadiantBeam");
        }
    }
}
