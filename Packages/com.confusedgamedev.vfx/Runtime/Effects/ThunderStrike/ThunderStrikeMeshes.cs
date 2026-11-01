using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    public static class ThunderStrikeMeshes
    {
        public const int MaxParticles = 512;

        private const uint Seed = 332140;

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
            for (int id = 34; id >= 0; id--)
            {
                int steps = id < 3 ? 96 : id < 11 ? 40 : id < 23 ? 48 : 20;
                var data = new Vector4(id < 3 ? 0f : id < 11 ? 1f : 2f, id, -1f, 0f);
                for (int step = 0; step < steps; step++)
                {
                    int first = builder.VertexCount;
                    for (int corner = 0; corner < 4; corner++)
                    {
                        builder.AddVertex(new Vector3((float)step / steps, (step + 1f) / steps, id), new Vector2(corner & 1, corner >> 1), data);
                    }
                    builder.AddIndices(first, first + 1, first + 2, first + 2, first + 1, first + 3);
                }
            }

            for (int id = 0; id < 2; id++)
            {
                builder.AddSurface(1, 1, (u, v) => new Vector3(u - 0.5f, v - 0.5f, 0f), new Vector4(3f, id, -1f, 0f));
            }

            builder.AddSurface(1, 1, (u, v) => new Vector3(u - 0.5f, 0f, v - 0.5f), new Vector4(4f, 0f, -1f, 0f));
            builder.AddSurface(1, 1, (u, v) => new Vector3(u - 0.5f, 0f, v - 0.5f), new Vector4(5f, 0f, -1f, 0f));
            return builder.Build("ThunderStrikeBody", VfxBurstMeshes.EffectBounds);
        }

        public static Mesh CreateParticles()
        {
            return VfxMeshes.CreateQuads("ThunderStrikeParticles", MaxParticles, VfxBurstMeshes.EffectBounds, seeds: VfxMeshes.CreateSeeds(MaxParticles, Seed, 0));
        }
    }
}
