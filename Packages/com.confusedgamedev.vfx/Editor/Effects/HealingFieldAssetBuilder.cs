using UnityEditor;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Editor
{
    public static class HealingFieldAssetBuilder
    {
        [VfxBuilder("HealingField")]
        [MenuItem("Tools/ConfusedGameDev/VFX/Rebuild Healing Sigil Assets")]
        public static void Build()
        {
            GameObject root = VfxAssetBuilder.Create<HealingFieldEffect, HealingFieldPreset>("HealingField", new[]
            {
                new VfxAssetBuilder.Layer("Aura", HealingFieldMeshes.CreateAura()),
                new VfxAssetBuilder.Layer("Sigil", HealingFieldMeshes.CreateSigil()),
                new VfxAssetBuilder.Layer("Particles", HealingFieldMeshes.CreateParticles())
            }, out _);
            VfxAssetBuilder.Save(root, "HealingField");
        }
    }
}
