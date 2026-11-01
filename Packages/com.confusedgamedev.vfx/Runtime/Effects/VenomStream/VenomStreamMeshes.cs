using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    public static class VenomStreamMeshes
    {
        public const int MaxParticles = 512;

        private const uint Seed = 422602;

        public static Mesh CreateBody()
        {
            var builder = new VfxMeshBuilder();

            // Closed teardrop slugs. Every visible gap separates complete volumes.
            for (int i = 0; i < 16; i++)
            {
                float phase = Mathf.Repeat(i / 8f + Mathf.Sin(i * 2.3f) * 0.018f + 1f, 1f);
                builder.AddSphere(10, 7, Vector3.one, new Vector4(phase, i * 2.37f, 0f, 0.14f + i % 3 * 0.035f));
            }

            // Detached droplets that follow the jet at any density.
            for (int i = 0; i < 5; i++)
            {
                builder.AddSphere(7, 5, new Vector3(0.09f, 0.065f, 0.065f), new Vector4(i / 5f + 0.03f, i * 2.19f, 2f, 0.26f));
            }

            float[] directions = { -0.4f, 0.65f, 1.8f, 3.05f, 4.65f };
            for (int i = 0; i < 5; i++)
            {
                float phase = Mathf.Repeat(i * 0.213f + 0.07f, 1f);
                float a = directions[i];
                AddTongue(builder, new Vector4(phase, a, 1f, 0.24f));

                float width = 0.10f + i % 2 * 0.025f;
                builder.AddSphere(8, 6, new Vector3(width, 0.12f + i % 3 * 0.018f, width), new Vector4(phase, a, 3f, 0.36f));
            }

            return builder.Build("VenomStreamBody", VfxMeshes.BeamBounds);
        }

        public static Mesh CreateDroplets()
        {
            var shape = new VfxMeshBuilder();
            Vector3[] corners =
            {
                new Vector3(1f, 1f, 1f).normalized, new Vector3(-1f, -1f, 1f).normalized,
                new Vector3(-1f, 1f, -1f).normalized, new Vector3(1f, -1f, -1f).normalized
            };

            foreach (int corner in new[] { 2, 1, 0, 0, 3, 2, 1, 3, 0, 2, 3, 1 })
            {
                shape.AddVertex(corners[corner], Vector2.zero);
            }

            shape.AddIndices(0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11);
            return VfxMeshBuilder.Instance("VenomStreamDroplets", shape, VfxMeshes.CreateSeeds(MaxParticles, Seed), VfxMeshes.BeamBounds);
        }

        // A flat, closed tongue along +X, narrowing toward its tip. The vertex shader places and bends it.
        private static void AddTongue(VfxMeshBuilder builder, Vector4 data)
        {
            const int Rows = 8;
            const int Sides = 6;

            var rings = new Vector3[Rows + 1, Sides];
            for (int row = 0; row <= Rows; row++)
            {
                float h = (float)row / Rows;
                float width = 0.17f * Mathf.Pow(1f - h, 0.72f) + 0.006f;
                float thickness = 0.065f * (1f - h) + 0.004f;
                for (int side = 0; side < Sides; side++)
                {
                    float a = side * Mathf.PI * 2f / Sides;
                    rings[row, side] = new Vector3(h, Mathf.Cos(a) * width, Mathf.Sin(a) * thickness);
                }
            }

            void Triangle(Vector3 a, Vector3 b, Vector3 c)
            {
                builder.AddFlatTriangle(a, b, c, Vector2.zero, Vector2.zero, Vector2.zero, data);
            }

            for (int side = 0; side < Sides; side++)
            {
                int next = (side + 1) % Sides;
                for (int row = 0; row < Rows; row++)
                {
                    Triangle(rings[row, side], rings[row + 1, side], rings[row + 1, next]);
                    Triangle(rings[row, side], rings[row + 1, next], rings[row, next]);
                }

                Triangle(Vector3.zero, rings[0, next], rings[0, side]);
                Triangle(Vector3.right, rings[Rows, side], rings[Rows, next]);
            }
        }
    }
}
