using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    public static class SmokePuffMeshes
    {
        public const int MaxParticles = 96;

        private const uint Seed = 220488;

        private static readonly int[] Maxima = { 96 };
        private static readonly float[] Weights = { 1f };

        /// <summary>Instances per layer for a density, split the way the source splits its budget.</summary>
        public static Vector4 LayerCounts(float density)
        {
            return VfxBurstMeshes.LayerCounts(MaxParticles, 0, density, Maxima, Weights);
        }

        public static Mesh CreateClouds()
        {
            return VfxMeshes.CreateQuads("SmokePuffClouds", MaxParticles, VfxBurstMeshes.EffectBounds, seeds: VfxMeshes.CreateSeeds(MaxParticles, Seed));
        }
    }
}
