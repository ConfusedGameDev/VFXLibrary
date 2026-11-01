using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    public static class AstralGateMeshes
    {
        public const int MaxParticles = 512;

        private const uint Seed = 385854;

        public static Mesh CreateFrame()
        {
            const float Tau = Mathf.PI * 2f;
            var pieces = new VfxPieceMeshBuilder();
            var center = new Vector3(0f, 1.45f, 0f);
            for (int i = 0; i < 16; i++)
            {
                float a = i * Tau / 16f;
                float b = (i + 0.80f) * Tau / 16f;
                AddArc(pieces.Builder, 0.92f, 1.08f, a, b, 1.35f, 0.18f, 3, center, new Vector4(i / 16f, a, 0f, 0.18f));
                pieces.EndPiece(center);
                AddArc(pieces.Builder, 0.975f, 1.01f, a + 0.025f, b - 0.025f, 1.35f, 0.025f, 3, new Vector3(0.107f, 1.45f, 0f), new Vector4(i / 16f, a, 1f, 0.92f));
                pieces.EndPiece(new Vector3(0.107f, 1.45f, 0f));
            }
            return pieces.Build("AstralGateFrame", VfxBurstMeshes.EffectBounds);
        }

        public static Mesh CreateMembrane()
        {
            // CircleGeometry(0.94, 48) turned to face +X, then stretched to the frame's height.
            var pieces = new VfxPieceMeshBuilder();
            var center = new Vector3(0f, 1.45f, 0f);
            var normal = Vector3.right;
            var data = Vector4.zero;
            pieces.Builder.AddLitVertex(center, normal, new Vector2(0.5f, 0.5f), data);
            for (int i = 0; i <= 48; i++)
            {
                float a = i * Mathf.PI * 2f / 48f;
                float x = Mathf.Cos(a);
                float y = Mathf.Sin(a);
                pieces.Builder.AddLitVertex(new Vector3(0f, y * 0.94f * 1.35f, -x * 0.94f) + center, normal, new Vector2((x + 1f) / 2f, (y + 1f) / 2f), data);
            }
            for (int i = 1; i <= 48; i++)
            {
                pieces.Builder.AddIndices(i, i + 1, 0);
            }
            pieces.EndPiece(center);
            return pieces.Build("AstralGateMembrane", VfxBurstMeshes.EffectBounds);
        }

        public static Mesh CreateParticles()
        {
            return VfxBurstMeshes.CreateTetrahedra("AstralGateParticles", MaxParticles, Seed);
        }

        // The source's arc(..., vertical = true): flat-shaded box sections, swept around X.
        private static void AddArc(VfxMeshBuilder builder, float inner, float outer, float start, float end, float height, float depth, int segments, Vector3 offset, Vector4 data)
        {
            Vector3 Point(float r, float a, float y)
            {
                return new Vector3(y, Mathf.Cos(a) * r * height, Mathf.Sin(a) * r) + offset;
            }

            void Tri(Vector3 a, Vector3 b, Vector3 c, Vector2 ua, Vector2 ub, Vector2 uc)
            {
                builder.AddFlatTriangle(a, b, c, ua, ub, uc, data);
            }

            for (int i = 0; i < segments; i++)
            {
                float t = (float)i / segments;
                float n = (i + 1f) / segments;
                float a = start + (end - start) * t;
                float b = start + (end - start) * n;
                Vector3 a0 = Point(inner, a, -depth / 2f), a1 = Point(outer, a, -depth / 2f), a2 = Point(outer, a, depth / 2f), a3 = Point(inner, a, depth / 2f);
                Vector3 b0 = Point(inner, b, -depth / 2f), b1 = Point(outer, b, -depth / 2f), b2 = Point(outer, b, depth / 2f), b3 = Point(inner, b, depth / 2f);
                Vector3[,] quads = { { a0, b0, b1, a1 }, { a1, b1, b2, a2 }, { a2, b2, b3, a3 }, { a3, b3, b0, a0 } };
                for (int q = 0; q < 4; q++)
                {
                    Tri(quads[q, 0], quads[q, 1], quads[q, 2], new Vector2(t, 0f), new Vector2(n, 0f), new Vector2(n, 1f));
                    Tri(quads[q, 0], quads[q, 2], quads[q, 3], new Vector2(t, 0f), new Vector2(n, 1f), new Vector2(t, 1f));
                }

                if (i == 0)
                {
                    Tri(a0, a1, a2, new Vector2(t, 0f), new Vector2(t, 1f), new Vector2(t, 1f));
                    Tri(a0, a2, a3, new Vector2(t, 0f), new Vector2(t, 1f), new Vector2(t, 0f));
                }

                if (i == segments - 1)
                {
                    Tri(b0, b2, b1, new Vector2(n, 0f), new Vector2(n, 1f), new Vector2(n, 1f));
                    Tri(b0, b3, b2, new Vector2(n, 0f), new Vector2(n, 0f), new Vector2(n, 1f));
                }
            }
        }
    }
}
