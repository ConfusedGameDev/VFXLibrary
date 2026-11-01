using UnityEditor;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Editor
{
    public static class MagicBarrierAssetBuilder
    {
        [VfxBuilder("MagicBarrier")]
        [MenuItem("Tools/ConfusedGameDev/VFX/Rebuild Magic Barrier Assets")]
        public static void Build()
        {
            GameObject root = VfxAssetBuilder.Create<MagicBarrierEffect, MagicBarrierPreset>("MagicBarrier", new[]
            {
                new VfxAssetBuilder.Layer("Aura", MagicBarrierMeshes.CreateAura()),
                new VfxAssetBuilder.Layer("Sigil", MagicBarrierMeshes.CreateSigil()),
                new VfxAssetBuilder.Layer("Shield", MagicBarrierMeshes.CreateShield()),
                new VfxAssetBuilder.Layer("Particles", MagicBarrierMeshes.CreateParticles())
            }, out _);
            VfxAssetBuilder.Save(root, "MagicBarrier");
        }
    }
}
