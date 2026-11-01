using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    public static class FlameSurgeMeshes
    {
        public const int MaxParticles = 512;

        private const uint Seed = 302119;

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
            for (int k = 0; k < 10; k++)
            {
                int tongue = k;
                builder.AddSurface(k < 3 ? 28 : 16, k < 3 ? 16 : 10, (u, v) => new Vector3(u, v, tongue), new Vector4(0f, k, k, 0f));
            }

            for (int k = 0; k < 12; k++)
            {
                int puff = k;
                builder.AddSurface(1, 1, (u, v) => new Vector3(u, v, puff), new Vector4(2f, k, Mathf.Floor(k * 5 / 12f), 0f));
            }
            return builder.Build("FlameSurgeBody", VfxBurstMeshes.EffectBounds);
        }

        public static Mesh CreateParticles()
        {
            return VfxMeshes.CreateQuads("FlameSurgeParticles", MaxParticles, VfxBurstMeshes.EffectBounds, seeds: VfxMeshes.CreateSeeds(MaxParticles, Seed, 0));
        }
    }
}
