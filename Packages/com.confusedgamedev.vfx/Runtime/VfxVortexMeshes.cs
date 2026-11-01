using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Mesh helpers and budget shared by the vortices, whose shape comes entirely from the shaders.</summary>
    public static class VfxVortexMeshes
    {
        // Layers in allocation order: streak particles, dust, debris.
        private static readonly int[] Maxima = { 1024, 96, 40 };
        private static readonly float[] Weights = { 1f, 0.16f, 0.055f };

        private const float GroundWidth = 7.25f;

        public static Vector4 LayerCounts(int cap, int fixedSlots, float density)
        {
            return VfxBurstMeshes.LayerCounts(cap, fixedSlots, density, Maxima, Weights);
        }

        /// <summary>
        /// The source's ribbon sheet: each blade is a grid whose vertices carry only coordinates.
        /// Position holds along, across and blade id. Billows, when any, are single quads ahead of the blades.
        /// </summary>
        public static Mesh CreateColumn(string name, int blades, int steps, int crossSteps, int billows = 0)
        {
            var builder = new VfxMeshBuilder();
            for (int id = 0; id < billows; id++)
            {
                AddBlade(builder, id, 1, 1);
            }
            for (int id = 0; id < blades; id++)
            {
                AddBlade(builder, billows + id, steps, crossSteps);
            }
            return builder.Build(name, VfxBurstMeshes.EffectBounds);
        }

        public static Mesh CreateGround(string name)
        {
            return VfxMeshes.CreateGrid(name, GroundWidth, 1, VfxBurstMeshes.EffectBounds);
        }

        public static Mesh CreateParticles(string name, int cap, uint seed)
        {
            return CreateQuads(name, cap, seed, 0);
        }

        public static Mesh CreateDust(string name, uint seed)
        {
            return CreateQuads(name, Maxima[1], seed, 1);
        }

        public static Mesh CreateDebris(string name, uint seed)
        {
            return CreateQuads(name, Maxima[2], seed, 2);
        }

        private static Mesh CreateQuads(string name, int count, uint seed, int layerIndex)
        {
            return VfxMeshes.CreateQuads(name, count, VfxBurstMeshes.EffectBounds, seeds: VfxMeshes.CreateSeeds(count, seed, layerIndex));
        }

        private static void AddBlade(VfxMeshBuilder builder, int id, int steps, int crossSteps)
        {
            int first = builder.VertexCount;
            for (int j = 0; j <= steps; j++)
            {
                for (int k = 0; k <= crossSteps; k++)
                {
                    float u = (float)j / steps;
                    float v = (float)k / crossSteps;
                    builder.AddVertex(new Vector3(u, v * 2f - 1f, id), new Vector2(u, v));
                }
            }

            int stride = crossSteps + 1;
            for (int j = 0; j < steps; j++)
            {
                for (int k = 0; k < crossSteps; k++)
                {
                    int i = first + j * stride + k;
                    builder.AddIndices(i, i + 1, i + stride, i + 1, i + stride + 1, i + stride);
                }
            }
        }
    }
}
