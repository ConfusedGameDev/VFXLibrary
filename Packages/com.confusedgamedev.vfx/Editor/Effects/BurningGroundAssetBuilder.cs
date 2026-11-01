using UnityEditor;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Editor
{
    public static class BurningGroundAssetBuilder
    {
        [VfxBuilder("BurningGround")]
        [MenuItem("Tools/ConfusedGameDev/VFX/Rebuild Flame-Etched Ground Assets")]
        public static void Build()
        {
            GameObject root = VfxAssetBuilder.Create<BurningGroundEffect, BurningGroundPreset>("BurningGround", new[]
            {
                new VfxAssetBuilder.Layer("Aura", BurningGroundMeshes.CreateAura()),
                new VfxAssetBuilder.Layer("Sigil", BurningGroundMeshes.CreateSigil()),
                new VfxAssetBuilder.Layer("Particles", BurningGroundMeshes.CreateParticles())
            }, out _);
            VfxAssetBuilder.Save(root, "BurningGround");
        }
    }
}
