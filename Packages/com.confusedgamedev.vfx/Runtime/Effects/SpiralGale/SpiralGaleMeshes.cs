using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    public static class SpiralGaleMeshes
    {
        public const int MaxParticles = 512;

        private const uint Seed = 412196;

        private static readonly Bounds EffectBounds = VfxMeshes.ProjectileBounds;

        public static Mesh CreateTrail()
        {
            return VfxMeshes.CreateSchoolTrail("SpiralGaleTrail", 4);
        }

        /// <summary>Seven twisted tubes, thinning at both ends.</summary>
        public static Mesh CreateBody()
        {
            var builder = new VfxMeshBuilder();
            for (int k = 0; k < 7; k++)
            {
                int ribbon = k;
                float kind = k % 3;
                builder.AddSurface(24, 6, (u, v) =>
                {
                    float a = u * (3.2f + kind * 0.45f) + ribbon * 2.39996f;
                    float b = v * Mathf.PI * 2f;
                    float r = 0.025f + 0.46f * Mathf.Pow(Mathf.Max(0f, Mathf.Sin(u * Mathf.PI * 0.85f)), 1.2f);
                    float w = Mathf.Sin(u * Mathf.PI) * (0.026f + kind * 0.013f);
                    float ring = r + Mathf.Cos(b) * w;
                    return new Vector3(0.98f - u * (1.6f + kind * 0.35f), Mathf.Cos(a) * ring, Mathf.Sin(a) * ring + Mathf.Sin(b) * w);
                }, new Vector4(k, 0f, 0f, 0f));
            }
            builder.ComputeNormals();
            return builder.Build("SpiralGaleBody", EffectBounds);
        }

        public static Mesh CreateParticles()
        {
            return VfxMeshes.CreateQuads("SpiralGaleParticles", MaxParticles, EffectBounds, seeds: VfxMeshes.CreateSeeds(MaxParticles, Seed));
        }

        public static Mesh CreateImpact()
        {
            var builder = new VfxMeshBuilder();
            for (int i = 0; i < 8; i++)
            {
                int ribbon = i;
                builder.AddPatch(4, 12, (u, v) => new Vector3(u, v, ribbon), part: i);
            }
            return builder.Build("SpiralGaleImpact", EffectBounds);
        }

        public static Mesh CreateGlow()
        {
            return VfxMeshes.CreateQuads("SpiralGaleGlow", 1, EffectBounds, 1.8f);
        }
    }
}
