using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    public static class PainterlyGrassMeshes
    {
        public const int MaxParticles = 512;

        private const int BladeClumps = 480;
        private const int FlowerStems = 32;
        private const uint Seed = 607319;

        // Holds the patch at size 2, with the wind's reach.
        private static readonly Bounds EffectBounds = new Bounds(new Vector3(0f, 1.2f, 0f), new Vector3(7f, 3.2f, 7f));

        private static readonly int[] Maxima = { BladeClumps, FlowerStems };
        private static readonly float[] Weights = { 15f / 16f, 1f / 16f };

        /// <summary>Clumps and flowers for a density, split the way the source splits its budget.</summary>
        public static Vector4 LayerCounts(float density)
        {
            return VfxBurstMeshes.LayerCounts(MaxParticles, 0, density, Maxima, Weights);
        }

        public static Mesh CreateBlades()
        {
            return VfxMeshBuilder.Instance("PainterlyGrassBlades", CreateShape(3, 3), VfxMeshes.CreateSeeds(BladeClumps, Seed, 0), EffectBounds);
        }

        public static Mesh CreateFlowers()
        {
            return VfxMeshBuilder.Instance("PainterlyGrassFlowers", CreateShape(6, 1), VfxMeshes.CreateSeeds(FlowerStems, Seed, 1), EffectBounds);
        }

        // A clump: strips in x and y, with the strip's number in z. The shader shapes them.
        private static VfxMeshBuilder CreateShape(int pieces, int segments)
        {
            var builder = new VfxMeshBuilder();
            for (int piece = 0; piece < pieces; piece++)
            {
                int first = builder.VertexCount;
                for (int j = 0; j <= segments; j++)
                {
                    for (int side = 0; side < 2; side++)
                    {
                        float h = j / (float)segments;
                        builder.AddVertex(new Vector3(side * 2 - 1, h, piece), new Vector2(side, h));
                    }
                }

                for (int j = 0; j < segments; j++)
                {
                    int i = first + j * 2;
                    builder.AddIndices(i, i + 1, i + 2, i + 1, i + 3, i + 2);
                }
            }
            return builder;
        }
    }
}
