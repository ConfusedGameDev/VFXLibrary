using UnityEditor;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Editor
{
    public static class IceShardAssetBuilder
    {
        [VfxBuilder("IceShard")]
        [MenuItem("Tools/ConfusedGameDev/VFX/Rebuild Frostcrystal Dart Assets")]
        public static void Build()
        {
            GameObject root = VfxAssetBuilder.Create<IceShardEffect, IceShardPreset>("IceShard", new[]
            {
                new VfxAssetBuilder.Layer("Core", IceShardMeshes.CreateCore()),
                new VfxAssetBuilder.Layer("Trails", IceShardMeshes.CreateTrails()),
                new VfxAssetBuilder.Layer("Particles", IceShardMeshes.CreateParticles()),
                new VfxAssetBuilder.Layer("Impact", IceShardMeshes.CreateImpact()),
                new VfxAssetBuilder.Layer("Glow", IceShardMeshes.CreateGlow())
            }, out Renderer[] renderers);

            VfxAssetBuilder.SaveProjectile<IceShardEffect>(root, "IceShard", renderers[3], renderers[4]);
        }
    }
}
