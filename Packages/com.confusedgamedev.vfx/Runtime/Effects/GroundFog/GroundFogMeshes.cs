using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    public static class GroundFogMeshes
    {
        public const int MaxParticles = 128;

        private const uint Seed = 202114;

        public static Mesh CreateClouds()
        {
            return VfxMeshes.CreateQuads("GroundFogClouds", MaxParticles, VfxBurstMeshes.EffectBounds, seeds: VfxMeshes.CreateSeeds(MaxParticles, Seed));
        }
    }
}
