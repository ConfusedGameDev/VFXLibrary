using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    public static class AstralConvergenceMeshes
    {
        public const int MaxParticles = 512;

        private const uint Seed = 402189;

        private static readonly int[] Maxima = { 512 };
        private static readonly float[] Weights = { 1f };

        /// <summary>Instances per layer for a density, split the way the source splits its budget.</summary>
        public static Vector4 LayerCounts(float density)
        {
            return VfxBurstMeshes.LayerCounts(MaxParticles, 0, density, Maxima, Weights);
        }

        public static Mesh CreateBody()
        {
            var builder = new VfxMeshBuilder();
            const float Tau = Mathf.PI * 2f;
            for (int k = 0; k < 3; k++)
            {
                float tilt = k * Tau / 3f;
                VfxGroundMeshes.AddTube(builder, u =>
                {
                    float a = u * Tau;
                    float x = Mathf.Cos(a) * 1.4f;
                    return new Vector3(x * Mathf.Cos(tilt), Mathf.Sin(a) * 0.8f, x * Mathf.Sin(tilt));
                }, u => 0.022f, 64, 4, new Vector4(0f, k, -1f, 0f));
            }

            var stars = new Vector3[12];
            for (int i = 0; i < 12; i++)
            {
                float a = i * 2.4f;
                float r = 0.75f + i % 3 * 0.25f;
                stars[i] = new Vector3(Mathf.Cos(a) * r, Mathf.Sin(i * 1.8f) * 0.8f, Mathf.Sin(a) * r);
                VfxGroundMeshes.AddGem(builder, stars[i], new Vector3(0.07f, 0.13f, 0.07f), a, new Vector4(1f, a, -1f, 0f));
                if (i > 0)
                {
                    Vector3 from = stars[i - 1];
                    Vector3 to = stars[i];
                    VfxGroundMeshes.AddTube(builder, u => Vector3.Lerp(from, to, u), u => 0.012f, 2, 3, new Vector4(1f, i, -1f, 0f));
                }
            }

            for (int i = 0; i < 20; i++)
            {
                float a = i * 2.4f;
                float y = Mathf.Sin(i * 2f) * 1.7f;
                VfxGroundMeshes.AddTube(builder, u => new Vector3(Mathf.Cos(a) * u * 2.1f, y * u, Mathf.Sin(a) * u * 2.1f), u => 0.055f * Mathf.Sin(u * Mathf.PI), 12, 4, new Vector4(2f, i * 0.5f, i, 0f));
            }
            return builder.Build("AstralConvergenceBody", VfxBurstMeshes.EffectBounds);
        }

        public static Mesh CreateParticles()
        {
            return VfxMeshes.CreateQuads("AstralConvergenceParticles", MaxParticles, VfxBurstMeshes.EffectBounds, seeds: VfxMeshes.CreateSeeds(MaxParticles, Seed, 0));
        }
    }
}
