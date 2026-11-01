using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    public static class SpatialSweepMeshes
    {
        public const int MaxParticles = 8;

        private const uint Seed = 829643;

        private static readonly int[] Maxima = { 8 };
        private static readonly float[] Weights = { 1f };

        /// <summary>Instances per layer for a density, split the way the source splits its budget.</summary>
        public static Vector4 LayerCounts(float density)
        {
            return VfxBurstMeshes.LayerCounts(MaxParticles, 0, density, Maxima, Weights);
        }

        public static Mesh CreateRefraction()
        {
            var builder = new VfxMeshBuilder();
            builder.AddPatch(8, 192, (u, v) => new Vector3(u - 0.5f, v - 0.5f, 0f));
            return builder.Build("SpatialSweepRefraction", VfxBurstMeshes.EffectBounds);
        }

        public static Mesh CreateHalo()
        {
            return VfxMeshes.CreateQuads("SpatialSweepHalo", 1, VfxBurstMeshes.EffectBounds, segments: 192);
        }

        public static Mesh CreateStreaks()
        {
            return VfxMeshes.CreateQuads("SpatialSweepStreaks", MaxParticles, VfxBurstMeshes.EffectBounds, segments: 192, seeds: VfxMeshes.CreateSeeds(MaxParticles, Seed));
        }

        public static Mesh CreateEdge()
        {
            return VfxMeshes.CreateQuads("SpatialSweepEdge", 1, VfxBurstMeshes.EffectBounds, segments: 192);
        }
    }
}
