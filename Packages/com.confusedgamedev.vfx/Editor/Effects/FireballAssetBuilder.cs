using UnityEditor;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Editor
{
    /// <summary>Regenerates the fireball's baked meshes, materials, default preset and prefab.</summary>
    public static class FireballAssetBuilder
    {
        [VfxBuilder("Fireball")]
        [MenuItem("Tools/ConfusedGameDev/VFX/Rebuild Fireball Assets")]
        public static void Build()
        {
            GameObject root = VfxAssetBuilder.Create<FireballEffect, FireballPreset>("Fireball", new[]
            {
                new VfxAssetBuilder.Layer("Core", FireballMeshes.CreateCore()),
                new VfxAssetBuilder.Layer("Particles", FireballMeshes.CreateParticles()),
                new VfxAssetBuilder.Layer("Impact", FireballMeshes.CreateImpact()),
                new VfxAssetBuilder.Layer("Glow", FireballMeshes.CreateGlow())
            }, out Renderer[] renderers);

            VfxAssetBuilder.SaveProjectile<FireballEffect>(root, "Fireball", renderers[2], renderers[3]);
        }
    }
}
