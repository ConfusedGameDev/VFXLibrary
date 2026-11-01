using UnityEditor;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Editor
{
    public static class FireExplosionAssetBuilder
    {
        [VfxBuilder("FireExplosion")]
        [MenuItem("Tools/ConfusedGameDev/VFX/Rebuild White-Hot Fireburst Assets")]
        public static void Build()
        {
            GameObject root = VfxAssetBuilder.Create<FireExplosionEffect, FireExplosionPreset>("FireExplosion", new[]
            {
                new VfxAssetBuilder.Layer("Volume", FireExplosionMeshes.CreateVolume()),
                new VfxAssetBuilder.Layer("Ground", FireExplosionMeshes.CreateGround()),
                new VfxAssetBuilder.Layer("Trails", FireExplosionMeshes.CreateTrails()),
                new VfxAssetBuilder.Layer("Halo", FireExplosionMeshes.CreateHalo()),
                new VfxAssetBuilder.Layer("Embers", FireExplosionMeshes.CreateEmbers())
            }, out _);
            VfxAssetBuilder.Save(root, "FireExplosion");
        }
    }
}
