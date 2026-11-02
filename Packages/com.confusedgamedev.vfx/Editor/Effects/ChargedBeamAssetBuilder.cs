using UnityEditor;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Editor
{
    public static class ChargedBeamAssetBuilder
    {
        [VfxBuilder("ChargedBeam")]
        [MenuItem("Tools/ConfusedGameDev/VFX/Rebuild Charged Light Cannon Assets")]
        public static void Build()
        {
            GameObject root = VfxAssetBuilder.Create<ChargedBeamEffect, ChargedBeamPreset>("ChargedBeam", new[]
            {
                new VfxAssetBuilder.Layer("Discs", ChargedBeamMeshes.CreateDiscs()),
                new VfxAssetBuilder.Layer("Lance", ChargedBeamMeshes.CreateLance()),
                new VfxAssetBuilder.Layer("Particles", ChargedBeamMeshes.CreateParticles()),
                new VfxAssetBuilder.Layer("Charge", ChargedBeamMeshes.CreateCharge()),
                new VfxAssetBuilder.Layer("Flares", ChargedBeamMeshes.CreateFlares())
            }, out _);

            VfxAssetBuilder.SaveBeam<ChargedBeamEffect>(root, "ChargedBeam");
        }
    }
}
