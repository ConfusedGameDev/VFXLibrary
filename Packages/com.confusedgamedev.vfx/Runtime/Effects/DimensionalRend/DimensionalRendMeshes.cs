using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    public static class DimensionalRendMeshes
    {
        public const int MaxParticles = 128;

        private const uint Seed = 671423;

        private static readonly int[] Maxima = { 128 };
        private static readonly float[] Weights = { 1f };

        /// <summary>Instances per layer for a density, split the way the source splits its budget.</summary>
        public static Vector4 LayerCounts(float density)
        {
            return VfxBurstMeshes.LayerCounts(MaxParticles, 0, density, Maxima, Weights);
        }

        public static Mesh CreateCuts()
        {
            // One unit box per cut, split along X. The vertex shader folds each into a window.
            var builder = new VfxMeshBuilder();
            for (int i = 0; i < 32; i++)
            {
                AddFace(builder, Vector3.forward, Vector3.right, Vector3.up, 16, i);
                AddFace(builder, Vector3.back, Vector3.left, Vector3.up, 16, i);
                AddFace(builder, Vector3.up, Vector3.right, Vector3.back, 16, i);
                AddFace(builder, Vector3.down, Vector3.right, Vector3.forward, 16, i);
                AddFace(builder, Vector3.right, Vector3.back, Vector3.up, 1, i);
                AddFace(builder, Vector3.left, Vector3.forward, Vector3.up, 1, i);
            }
            return builder.Build("DimensionalRendCuts", VfxBurstMeshes.EffectBounds);
        }

        public static Mesh CreateGlow()
        {
            // Thirty-two blades, then thirty-two delayed traces flagged in UV1.x.
            var builder = new VfxMeshBuilder();
            for (int echo = 0; echo < 2; echo++)
            {
                for (int i = 0; i < 32; i++)
                {
                    builder.AddPatch(1, echo == 1 ? 8 : 16, (u, v) => new Vector3(u * 2f - 1f, v * 2f - 1f, 0f), new Vector4(echo, 0f, 0f, 0f), i);
                }
            }
            return builder.Build("DimensionalRendGlow", VfxBurstMeshes.EffectBounds);
        }

        public static Mesh CreateShards()
        {
            // A quad whose top corners merge on triangular seeds, with the front winding only.
            const float H = 0.57735026f;
            Vector3 a = new Vector3(-H, -H, 0f), b = new Vector3(H, -H, 0f), c = new Vector3(H, H, 0f), d = new Vector3(-H, H, 0f);
            var shape = new VfxMeshBuilder();
            foreach (Vector3 corner in new[] { a, b, c, a, c, d, c, b, a, d, c, a })
            {
                shape.AddVertex(corner, Vector2.zero);
            }
            shape.AddIndices(0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11);
            return VfxMeshBuilder.Instance("DimensionalRendShards", shape, VfxMeshes.CreateSeeds(MaxParticles, Seed), VfxBurstMeshes.EffectBounds);
        }

        public static Mesh CreateImpact()
        {
            var builder = new VfxMeshBuilder();
            builder.AddPatch(1, 1, (u, v) => new Vector3(u * 2f - 1f, v * 2f - 1f, 0f));
            return builder.Build("DimensionalRendImpact", VfxBurstMeshes.EffectBounds);
        }

        // A face of the source's 2x2x2 box, wound outward. right x up is the face's normal.
        private static void AddFace(VfxMeshBuilder builder, Vector3 normal, Vector3 right, Vector3 up, int columns, int unit)
        {
            builder.AddPatch(1, columns, (u, v) => normal + right * (1f - u * 2f) + up * (v * 2f - 1f), default, unit);
        }
    }
}
