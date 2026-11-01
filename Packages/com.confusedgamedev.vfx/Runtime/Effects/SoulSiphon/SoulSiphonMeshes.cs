using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    public static class SoulSiphonMeshes
    {
        public const int MaxParticles = 512;

        private const uint Seed = 395041;

        public static Mesh CreateBody()
        {
            const float Tau = Mathf.PI * 2f;
            var builder = new VfxMeshBuilder();

            for (int strand = 0; strand < 3; strand++)
            {
                builder.AddCylinder(0.011f, 0.011f, 4.8f, 5, 36, TurnLeft, Vector3.zero, new Vector4(strand / 3f, strand * Tau / 3f, 0f, 0.25f));
            }

            // Fixed capacity: quantity only selects and phases the paired heads and tails.
            for (int i = 0; i < 18; i++)
            {
                float a = i % 3 * Tau / 3f;
                builder.AddSphere(8, 5, new Vector3(0.22f, 0.15f, 0.15f), new Vector4(i / 9f, a, 1f, 0.68f));
                builder.AddCylinder(0f, 0.12f, 0.44f, 5, 1, TurnRight, new Vector3(0.24f, 0f, 0f), new Vector4(i / 9f, a, 2f, 0.16f));
            }

            for (int end = 0; end < 2; end++)
            {
                for (int i = 0; i < 5; i++)
                {
                    AddArc(builder, end == 0 ? 0.27f : 0.16f, end == 0 ? 0.31f : 0.19f, i * Tau / 5f, (i + 0.7f) * Tau / 5f, 0.035f, end == 0 ? -2.4f : 2.4f, new Vector4(i / 5f, i * Tau / 5f, 3f + end, 0.5f));
                }
            }

            return builder.Build("SoulSiphonBody", VfxMeshes.BeamBounds);
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
            return VfxMeshBuilder.Instance("SoulSiphonDroplets", shape, VfxMeshes.CreateSeeds(MaxParticles, Seed), VfxMeshes.BeamBounds);
        }

        private static Vector3 TurnLeft(Vector3 v)
        {
            return new Vector3(-v.y, v.x, v.z);
        }

        private static Vector3 TurnRight(Vector3 v)
        {
            return new Vector3(v.y, -v.x, v.z);
        }

        // A flat-shaded box bent around the beam, in four sections, facing along it at x.
        private static void AddArc(VfxMeshBuilder builder, float inner, float outer, float start, float end, float depth, float x, Vector4 data)
        {
            const int Segments = 4;

            Vector3 Point(float radius, float a, float along)
            {
                return new Vector3(along + x, Mathf.Cos(a) * radius, Mathf.Sin(a) * radius);
            }

            void Quad(Vector3 q, Vector3 r, Vector3 s, Vector3 v)
            {
                builder.AddFlatTriangle(q, r, s, Vector2.zero, Vector2.zero, Vector2.zero, data);
                builder.AddFlatTriangle(q, s, v, Vector2.zero, Vector2.zero, Vector2.zero, data);
            }

            for (int i = 0; i < Segments; i++)
            {
                float a = Mathf.Lerp(start, end, (float)i / Segments);
                float b = Mathf.Lerp(start, end, (i + 1f) / Segments);
                Vector3 a0 = Point(inner, a, -depth / 2f);
                Vector3 a1 = Point(outer, a, -depth / 2f);
                Vector3 a2 = Point(outer, a, depth / 2f);
                Vector3 a3 = Point(inner, a, depth / 2f);
                Vector3 b0 = Point(inner, b, -depth / 2f);
                Vector3 b1 = Point(outer, b, -depth / 2f);
                Vector3 b2 = Point(outer, b, depth / 2f);
                Vector3 b3 = Point(inner, b, depth / 2f);

                Quad(a0, b0, b1, a1);
                Quad(a1, b1, b2, a2);
                Quad(a2, b2, b3, a3);
                Quad(a3, b3, b0, a0);

                if (i == 0)
                {
                    Quad(a0, a1, a2, a3);
                }

                if (i == Segments - 1)
                {
                    Quad(b0, b3, b2, b1);
                }
            }
        }
    }
}
