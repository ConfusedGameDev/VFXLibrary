using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    public static class TidalSurgeMeshes
    {
        public const int MaxParticles = 512;

        private const uint Seed = 382175;

        private static readonly int[] Maxima = { 512 };
        private static readonly float[] Weights = { 1f };

        /// <summary>Instances per layer for a density, split the way the source splits its budget.</summary>
        public static Vector4 LayerCounts(float density)
        {
            return VfxBurstMeshes.LayerCounts(MaxParticles, 12, density, Maxima, Weights);
        }

        public static Mesh CreateBody()
        {
            var builder = new VfxMeshBuilder();
            builder.AddSurface(64, 20, (u, v) => new Vector3(u, v, 0f), new Vector4(0f, 0f, -1f, 0f));
            builder.AddSurface(64, 4, (u, v) => new Vector3(u, 0.37f + v * 0.26f, 0f), new Vector4(1f, 0f, -1f, 0f));
            for (int k = 0; k < 12; k++)
            {
                int puff = k;
                builder.AddSurface(1, 1, (u, v) => new Vector3(u, v, puff), new Vector4(2f, k, -1f, 0f));
            }
            return builder.Build("TidalSurgeBody", VfxBurstMeshes.EffectBounds);
        }

        public static Mesh CreateParticles()
        {
            return VfxMeshes.CreateQuads("TidalSurgeParticles", MaxParticles, VfxBurstMeshes.EffectBounds, seeds: VfxMeshes.CreateSeeds(MaxParticles, Seed, 0));
        }
    }
}
