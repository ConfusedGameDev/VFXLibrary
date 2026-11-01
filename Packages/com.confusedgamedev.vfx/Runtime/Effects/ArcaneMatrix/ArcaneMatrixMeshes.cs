using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    public static class ArcaneMatrixMeshes
    {
        public const int MaxParticles = 512;

        private const uint Seed = 322133;

        private static readonly Vector2[] Extras =
        {
            new Vector2(0.425f, 0.425f), new Vector2(-0.425f, 0.425f), new Vector2(0.425f, -0.425f),
            new Vector2(-0.425f, -0.425f), new Vector2(0f, 0.425f), new Vector2(0f, -0.425f),
            new Vector2(0.425f, 0f), new Vector2(-0.425f, 0f), new Vector2(0.425f, 0.85f)
        };

        public static Mesh CreateSigil()
        {
            return VfxGroundMeshes.CreateFlat("ArcaneMatrixSigil", 3.5f);
        }

        /// <summary>The ground lattice, then a gem and ring for each of the 18 crystal slots. UV1 holds phase and quantity unit.</summary>
        public static Mesh CreateBody()
        {
            var builder = new VfxMeshBuilder();
            for (int i = -2; i <= 2; i++)
            {
                float line = i * 0.65f;
                VfxGroundMeshes.AddTube(builder, u => new Vector3(u * 2.6f - 1.3f, 0.08f, line), u => 0.018f, 2, 4, new Vector4(0f, -1f, 0f, 0f));
                VfxGroundMeshes.AddTube(builder, u => new Vector3(line, 0.08f, u * 2.6f - 1.3f), u => 0.018f, 2, 4, new Vector4(0f, -1f, 0f, 0f));
            }

            for (int i = 0; i < 18; i++)
            {
                Vector2 slot = i < 9 ? new Vector2((i % 3 - 1) * 0.85f, (i / 3 - 1) * 0.85f) : Extras[i - 9];
                float tier = (i % 3) * 0.22f;
                float phase = i * 0.6f;
                var extra = new Vector4(phase, i, 0f, 0f);
                VfxGroundMeshes.AddGem(builder, new Vector3(slot.x, 0.45f + tier, slot.y), new Vector3(0.09f, 0.15f, 0.09f), phase, extra, 1f);
                VfxGroundMeshes.AddTube(builder, u => new Vector3(
                    slot.x + Mathf.Cos(u * Mathf.PI * 2f) * 0.24f,
                    0.42f + tier,
                    slot.y + Mathf.Sin(u * Mathf.PI * 2f) * 0.24f), u => 0.018f, 4, 4, extra, 1f);
            }

            builder.ComputeNormals();
            return builder.Build("ArcaneMatrixBody", VfxGroundMeshes.EffectBounds);
        }

        public static Mesh CreateParticles()
        {
            return VfxGroundMeshes.CreateParticles("ArcaneMatrixParticles", MaxParticles, Seed);
        }
    }
}
