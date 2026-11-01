using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    public static class FrostWheelMeshes
    {
        public const int MaxParticles = 512;

        private const uint Seed = 312126;

        private static readonly Bounds EffectBounds = VfxMeshes.ProjectileBounds;

        public static Mesh CreateTrail()
        {
            return VfxMeshes.CreateSchoolTrail("FrostWheelTrail", 4);
        }

        /// <summary>A smooth torus and nine flat-shaded gem teeth, in the wheel plane.</summary>
        public static Mesh CreateBody()
        {
            var builder = new VfxMeshBuilder();
            builder.AddSurface(56, 8, (u, v) =>
            {
                float a = u * Mathf.PI * 2f;
                float b = v * Mathf.PI * 2f;
                float r = 0.65f + 0.16f * Mathf.Cos(b);
                return new Vector3(r * Mathf.Cos(a), r * Mathf.Sin(a), 0.13f * Mathf.Sin(b));
            });

            for (int i = 0; i < 9; i++)
            {
                float a = i * Mathf.PI * 2f / 9f;
                var scale = new Vector3(0.12f, 0.19f + i % 3 * 0.035f, 0.13f);
                var offset = new Vector3(Mathf.Cos(a) * 0.8f, Mathf.Sin(a) * 0.8f, 0.02f);
                float turn = a - Mathf.PI * 0.5f;
                float c = Mathf.Cos(turn);
                float s = Mathf.Sin(turn);
                builder.AddOctahedron(1f, p =>
                {
                    p = Vector3.Scale(p, scale);
                    return new Vector3(p.x * c - p.y * s, p.x * s + p.y * c, p.z) + offset;
                });
            }
            builder.ComputeNormals();
            return builder.Build("FrostWheelBody", EffectBounds);
        }

        public static Mesh CreateParticles()
        {
            return VfxMeshes.CreateQuads("FrostWheelParticles", MaxParticles, EffectBounds, seeds: VfxMeshes.CreateSeeds(MaxParticles, Seed));
        }

        public static Mesh CreateImpact()
        {
            var builder = new VfxMeshBuilder();
            for (int i = 0; i < 7; i++)
            {
                int shard = i;
                float angle = i * 0.897f;
                float depth = 0.08f + i % 3 * 0.22f;
                var center = new Vector3(depth, Mathf.Cos(angle) * 0.5f, Mathf.Sin(angle) * 0.5f);
                builder.AddPatch(3, 8, (u, v) =>
                {
                    float a = angle + u * 0.63f;
                    float r = 0.48f + v * 0.18f;
                    return new Vector3(depth + Mathf.Sin(v * 3.14159f) * 0.13f + Mathf.Sin(a * 2f + shard) * 0.12f, Mathf.Cos(a) * r, Mathf.Sin(a) * r);
                }, center, i);
            }
            return builder.Build("FrostWheelImpact", EffectBounds);
        }

        public static Mesh CreateGlow()
        {
            return VfxMeshes.CreateQuads("FrostWheelGlow", 1, EffectBounds, 1.8f);
        }
    }
}
