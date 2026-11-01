using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    public static class AzureSweepMeshes
    {
        public const int MaxParticles = 12;

        private const uint Seed = 829641;

        private static readonly int[] Maxima = { 12 };
        private static readonly float[] Weights = { 1f };

        /// <summary>Instances per layer for a density, split the way the source splits its budget.</summary>
        public static Vector4 LayerCounts(float density)
        {
            return VfxBurstMeshes.LayerCounts(MaxParticles, 0, density, Maxima, Weights);
        }

        public static Mesh CreateBlade()
        {
            return VfxMeshes.CreateQuads("AzureSweepBlade", 1, VfxBurstMeshes.EffectBounds, segments: 192);
        }

        public static Mesh CreateHalo()
        {
            return VfxMeshes.CreateQuads("AzureSweepHalo", 1, VfxBurstMeshes.EffectBounds, segments: 192);
        }

        public static Mesh CreateStreaks()
        {
            return VfxMeshes.CreateQuads("AzureSweepStreaks", MaxParticles, VfxBurstMeshes.EffectBounds, segments: 192, seeds: VfxMeshes.CreateSeeds(MaxParticles, Seed));
        }

        public static Mesh CreateEdge()
        {
            return VfxMeshes.CreateQuads("AzureSweepEdge", 1, VfxBurstMeshes.EffectBounds, segments: 192);
        }
    }
}
