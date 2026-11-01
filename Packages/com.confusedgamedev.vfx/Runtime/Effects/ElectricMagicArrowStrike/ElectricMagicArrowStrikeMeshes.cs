using System.Collections.Generic;
using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    public static class ElectricMagicArrowStrikeMeshes
    {
        public const int MaxParticles = 256;

        private const uint Seed = 829646;

        // Holds the lightning at size 2, from the trail's end to past the tip.
        public static readonly Bounds EffectBounds = new Bounds(new Vector3(0f, 0f, -2f), new Vector3(16f, 16f, 24f));

        public static ElectricArrowPool CreateArcPool()
        {
            return Runtime(new ElectricArrowPool("ElectricMagicArrowStrikeArcs", 4, 3, 32));
        }

        public static ElectricArrowPool CreateTrailPool()
        {
            return Runtime(new ElectricArrowPool("ElectricMagicArrowStrikeTrails", 3, 0, 16));
        }

        public static ElectricArrowPool CreateBlastPool()
        {
            return Runtime(new ElectricArrowPool("ElectricMagicArrowStrikeImpact", 8, 3, 32, 2));
        }

        public static Mesh CreateSigil()
        {
            return VfxMeshes.CreateQuads("ElectricMagicArrowStrikeSigil", 1, EffectBounds, 2.6f);
        }

        // The baked lightning only holds the layout. Play swaps in a dynamic copy.
        public static Mesh CreateArcs()
        {
            return new ElectricArrowPool("ElectricMagicArrowStrikeArcs", 4, 3, 32).Mesh;
        }

        public static Mesh CreateTrails()
        {
            return new ElectricArrowPool("ElectricMagicArrowStrikeTrails", 3, 0, 16).Mesh;
        }

        public static Mesh CreateImpact()
        {
            return new ElectricArrowPool("ElectricMagicArrowStrikeImpact", 8, 3, 32, 2).Mesh;
        }

        public static Mesh CreateGlow()
        {
            return VfxMeshes.CreateQuads("ElectricMagicArrowStrikeGlow", 1, EffectBounds, 2f);
        }

        public static Mesh CreateParticles()
        {
            return VfxMeshes.CreateQuads("ElectricMagicArrowStrikeParticles", MaxParticles, EffectBounds, seeds: VfxMeshes.CreateSeeds(MaxParticles, Seed));
        }

        public static Mesh CreateHalo()
        {
            var builder = new VfxMeshBuilder();
            for (int k = 0; k < 3; k++)
            {
                float a = k * Mathf.PI / 3f;
                float c = Mathf.Cos(a) * 0.95f;
                float s = Mathf.Sin(a) * 0.95f;
                int n = builder.VertexCount;
                builder.AddVertex(new Vector3(-2f, -c, -s), new Vector2(0f, 0f));
                builder.AddVertex(new Vector3(1.9f, -c, -s), new Vector2(1f, 0f));
                builder.AddVertex(new Vector3(1.9f, c, s), new Vector2(1f, 1f));
                builder.AddVertex(new Vector3(-2f, c, s), new Vector2(0f, 1f));
                builder.AddIndices(n, n + 1, n + 2, n, n + 2, n + 3);
            }
            return builder.Build("ElectricMagicArrowStrikeHalo", EffectBounds);
        }

        /// <summary>A narrow white core, four detached hooked blades and four tail fins, flat-shaded.</summary>
        public static Mesh CreateCore()
        {
            var p = new List<Vector3>();
            var blade = new List<float>();
            var indices = new List<int>();
            float[,] rings = { { -1.7f, 0f }, { -1.48f, 0.045f }, { 0.40f, 0.055f }, { 1.18f, 0.09f }, { 1.7f, 0f } };
            int ringCount = rings.GetLength(0);
            for (int i = 0; i < ringCount; i++)
            {
                for (int j = 0; j < 4; j++)
                {
                    float a = j * Mathf.PI / 2f + Mathf.PI / 4f;
                    p.Add(new Vector3(rings[i, 0], Mathf.Cos(a) * rings[i, 1], Mathf.Sin(a) * rings[i, 1]));
                    blade.Add(0f);
                }
            }

            for (int i = 0; i < ringCount - 1; i++)
            {
                for (int j = 0; j < 4; j++)
                {
                    int a = i * 4 + j;
                    int b = i * 4 + (j + 1) % 4;
                    indices.AddRange(new[] { a, b, a + 4, b, b + 4, a + 4 });
                }
            }

            float[,] outline = { { 0.18f, 0.49f }, { 0.60f, 0.46f }, { 1.60f, 0.055f }, { 0.89f, 0.21f }, { 0.46f, 0.24f } };
            for (int j = 0; j < 4; j++)
            {
                float a = j * Mathf.PI / 2f + Mathf.PI / 4f;
                float c = Mathf.Cos(a);
                float s = Mathf.Sin(a);
                int n = p.Count;
                for (int side = -1; side <= 1; side += 2)
                {
                    for (int k = 0; k < 5; k++)
                    {
                        float r = outline[k, 1];
                        float w = (0.035f + 0.055f * Mathf.Min(1f, r / 0.3f)) * side;
                        p.Add(new Vector3(outline[k, 0], c * r - s * w, s * r + c * w));
                        blade.Add(1f);
                    }
                }

                for (int k = 1; k < 4; k++)
                {
                    indices.AddRange(new[] { n, n + k + 1, n + k, n + 5, n + 5 + k, n + 6 + k });
                }

                for (int k = 0; k < 5; k++)
                {
                    int b = (k + 1) % 5;
                    indices.AddRange(new[] { n + k, n + b, n + k + 5, n + b, n + b + 5, n + k + 5 });
                }
            }

            for (int j = 0; j < 4; j++)
            {
                float a = j * Mathf.PI / 2f;
                float c = Mathf.Cos(a);
                float s = Mathf.Sin(a);
                int n = p.Count;
                p.Add(new Vector3(-1.62f, c * 0.06f, s * 0.06f));
                p.Add(new Vector3(-1.48f, c * 0.18f, s * 0.18f));
                p.Add(new Vector3(-0.92f, c * 0.06f, s * 0.06f));
                p.Add(new Vector3(-1.45f, c * 0.06f - s * 0.035f, s * 0.06f + c * 0.035f));
                blade.AddRange(new[] { 1f, 1f, 1f, 1f });
                indices.AddRange(new[] { n, n + 1, n + 3, n + 1, n + 2, n + 3, n + 2, n, n + 3, n, n + 2, n + 1 });
            }

            var builder = new VfxMeshBuilder();
            for (int i = 0; i < indices.Count; i += 3)
            {
                int a = indices[i];
                builder.AddFlatTriangle(p[a], p[indices[i + 1]], p[indices[i + 2]], Vector2.zero, Vector2.zero, Vector2.zero, new Vector4(blade[a], 0f, 0f, 0f));
            }
            return builder.Build("ElectricMagicArrowStrikeCore", EffectBounds);
        }

        private static ElectricArrowPool Runtime(ElectricArrowPool pool)
        {
            pool.Mesh.hideFlags = HideFlags.DontSave;
            pool.Mesh.MarkDynamic();
            return pool;
        }
    }
}
