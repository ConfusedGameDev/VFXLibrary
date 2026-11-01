using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    public static class SmokeColumnMeshes
    {
        public const int MaxParticles = 128;

        private const uint Seed = 192927;

        public static Mesh CreateClouds()
        {
            return VfxMeshes.CreateQuads("SmokeColumnClouds", MaxParticles, VfxBurstMeshes.EffectBounds, seeds: VfxMeshes.CreateSeeds(MaxParticles, Seed));
        }
    }
}
