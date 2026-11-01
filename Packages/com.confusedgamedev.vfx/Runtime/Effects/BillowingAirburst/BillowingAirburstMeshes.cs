using System.Collections.Generic;
using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    public static class BillowingAirburstMeshes
    {
        public const int MaxParticles = 128;

        /// <summary>Jets a cast picks. Quantity shows the first of them.</summary>
        public const int Jets = 6;

        private const uint Seed = 829648;
        private const int LobesPerJet = 24;

        // Holds the jets and embers at full size.
        private static readonly Bounds Bounds = new Bounds(Vector3.zero, new Vector3(36f, 36f, 36f));
        private static readonly List<Lobe> Lobes = CreateLobes();

        private static readonly int[] Maxima = { 128 };
        private static readonly float[] Weights = { 1f };

        /// <summary>Instances per layer for a density, split the way the source splits its budget.</summary>
        public static Vector4 LayerCounts(float density)
        {
            return VfxBurstMeshes.LayerCounts(MaxParticles, 0, density, Maxima, Weights);
        }

        public static Mesh CreateGlow()
        {
            var builder = new VfxMeshBuilder();
            var data = new List<Vector4>();
            var corners = new[] { new Vector2(-1f, -1f), new Vector2(1f, -1f), new Vector2(-1f, 1f), new Vector2(1f, 1f) };
            foreach (Lobe lobe in Lobes)
            {
                if (!lobe.Glows)
                {
                    continue;
                }

                int first = builder.VertexCount;
                foreach (Vector2 corner in corners)
                {
                    builder.AddVertex(corner, (corner + Vector2.one) * 0.5f, lobe.Shape);
                    data.Add(lobe.Data);
                }

                builder.AddIndices(first, first + 1, first + 2, first + 2, first + 1, first + 3);
            }

            Mesh mesh = builder.Build("BillowingAirburstGlow", Bounds);
            mesh.SetUVs(2, data);
            return mesh;
        }

        public static Mesh CreateCore()
        {
            return CreateVolume("BillowingAirburstCore", false, 40, 28);
        }

        public static Mesh CreateJets()
        {
            return CreateVolume("BillowingAirburstJets", true, 20, 14);
        }

        public static Mesh CreateWave()
        {
            return VfxMeshes.CreateQuads("BillowingAirburstWave", 1, Bounds);
        }

        public static Mesh CreateArcs()
        {
            var builder = new VfxMeshBuilder();
            for (int id = 0; id < 2; id++)
            {
                int offset = builder.VertexCount;
                for (int i = 0; i <= 96; i++)
                {
                    builder.AddVertex(Vector3.zero, new Vector2(i / 96f, 0f), new Vector4(id, 0f, 0f, 0f));
                    builder.AddVertex(Vector3.zero, new Vector2(i / 96f, 1f), new Vector4(id, 0f, 0f, 0f));
                }

                for (int i = 0; i < 96; i++)
                {
                    int a = offset + i * 2;
                    builder.AddIndices(a, a + 2, a + 1, a + 1, a + 2, a + 3);
                }
            }
            return builder.Build("BillowingAirburstArcs", Bounds);
        }

        public static Mesh CreateFlash()
        {
            return VfxMeshes.CreateQuads("BillowingAirburstFlash", 1, Bounds);
        }

        public static Mesh CreateEmbers()
        {
            var shape = new VfxMeshBuilder();
            for (int i = 0; i <= 28; i++)
            {
                shape.AddVertex(Vector3.zero, new Vector2(i / 28f, 0f));
                shape.AddVertex(Vector3.zero, new Vector2(i / 28f, 1f));
                if (i < 28)
                {
                    int a = i * 2;
                    shape.AddIndices(a, a + 2, a + 1, a + 1, a + 2, a + 3);
                }
            }

            // A head for each trail: z tells the two apart.
            int head = shape.VertexCount;
            shape.AddVertex(new Vector3(-0.5f, -0.5f, 1f), new Vector2(0f, 0f));
            shape.AddVertex(new Vector3(0.5f, -0.5f, 1f), new Vector2(1f, 0f));
            shape.AddVertex(new Vector3(-0.5f, 0.5f, 1f), new Vector2(0f, 1f));
            shape.AddVertex(new Vector3(0.5f, 0.5f, 1f), new Vector2(1f, 1f));
            shape.AddIndices(head, head + 1, head + 2, head + 2, head + 1, head + 3);
            return VfxMeshBuilder.Instance("BillowingAirburstEmbers", shape, VfxMeshes.CreateSeeds(MaxParticles, Seed), Bounds);
        }

        /// <summary>Picks a cast's six separated jets, and returns its noise offset.</summary>
        public static Vector4 RollCast(uint variationSeed, Vector4[] paths, Vector4[] bends)
        {
            uint v = variationSeed ^ Seed;
            float Next()
            {
                v = unchecked(v * 1664525u + 1013904223u);
                return (float)(v / 4294967296.0);
            }

            for (int i = 0; i < Jets; i++)
            {
                float x = 0f;
                float y = 0f;
                float z = 0f;
                bool accepted = false;
                for (int attempt = 0; attempt < 64 && !accepted; attempt++)
                {
                    y = Next() * 1.84f - 0.92f;
                    float a = Next() * Mathf.PI * 2f;
                    float r = Mathf.Sqrt(1f - y * y);
                    x = Mathf.Cos(a) * r;
                    z = Mathf.Sin(a) * r;
                    accepted = true;
                    for (int j = 0; j < i; j++)
                    {
                        accepted &= x * paths[j].x + y * paths[j].y + z * paths[j].z < 0.78f;
                    }
                }

                if (!accepted)
                {
                    float best = float.PositiveInfinity;
                    for (int k = 0; k < 192; k++)
                    {
                        float fy = 1f - 2f * (k + 0.5f) / 192f;
                        float fa = k * 2.399963f;
                        float fr = Mathf.Sqrt(1f - fy * fy);
                        float fx = Mathf.Cos(fa) * fr;
                        float fz = Mathf.Sin(fa) * fr;
                        float score = -1f;
                        for (int j = 0; j < i; j++)
                        {
                            score = Mathf.Max(score, fx * paths[j].x + fy * paths[j].y + fz * paths[j].z);
                        }

                        if (score < best)
                        {
                            best = score;
                            x = fx;
                            y = fy;
                            z = fz;
                        }
                    }
                }

                paths[i] = new Vector4(x, y, z, 3.4f + Next() * 1.2f);
                float bendX = (Next() - 0.5f) * 0.8f;
                float bendY = (Next() - 0.5f) * 0.65f;
                float bendZ = Next() * 0.035f;
                bends[i] = new Vector4(bendX, bendY, bendZ, 0.82f + Next() * 0.30f);
            }

            float offsetX = Next() * 19f;
            float offsetY = Next() * 19f;
            return new Vector4(offsetX, offsetY, Next() * 19f, 0f);
        }

        // Every lobe of a volume, each a sphere carrying its own center, radius and seeds.
        private static Mesh CreateVolume(string name, bool jets, int width, int height)
        {
            var builder = new VfxMeshBuilder();
            var data = new List<Vector4>();
            foreach (Lobe lobe in Lobes)
            {
                if (lobe.Data.y >= 0f != jets)
                {
                    continue;
                }

                int offset = builder.VertexCount;
                for (int iy = 0; iy <= height; iy++)
                {
                    float v = (float)iy / height;
                    for (int ix = 0; ix <= width; ix++)
                    {
                        float u = (float)ix / width;
                        var p = new Vector3(-Mathf.Cos(u * Mathf.PI * 2f) * Mathf.Sin(v * Mathf.PI), Mathf.Cos(v * Mathf.PI), Mathf.Sin(u * Mathf.PI * 2f) * Mathf.Sin(v * Mathf.PI));
                        builder.AddLitVertex(p, p, Vector2.zero, lobe.Shape);
                        data.Add(lobe.Data);
                    }
                }

                for (int iy = 0; iy < height; iy++)
                {
                    for (int ix = 0; ix < width; ix++)
                    {
                        int a = offset + iy * (width + 1) + ix + 1;
                        int b = offset + iy * (width + 1) + ix;
                        int c = offset + (iy + 1) * (width + 1) + ix;
                        int d = offset + (iy + 1) * (width + 1) + ix + 1;
                        if (iy != 0)
                        {
                            builder.AddIndices(a, b, d);
                        }

                        if (iy != height - 1)
                        {
                            builder.AddIndices(b, c, d);
                        }
                    }
                }
            }

            Mesh mesh = builder.Build(name, Bounds);
            mesh.SetUVs(2, data);
            return mesh;
        }

        private static List<Lobe> CreateLobes()
        {
            var lobes = new List<Lobe>();
            uint state = Seed;
            float Next()
            {
                state = unchecked(state * 1664525u + 1013904223u);
                return (float)(state / 4294967296.0);
            }

            for (int pass = 0; pass < 2; pass++)
            {
                bool jets = pass == 1;
                int total = jets ? Jets * LobesPerJet : 9;
                for (int i = 0; i < total; i++)
                {
                    int jet = jets ? i / LobesPerJet : -1;
                    int k = jets ? i % LobesPerJet : i;
                    float a = i * 2.399963f + (Next() - 0.5f) * 0.35f;
                    float z = 1f - 2f * (i + 0.5f) / total;
                    float radial = Mathf.Sqrt(Mathf.Max(0f, 1f - z * z));
                    float u = jets ? k / (LobesPerJet - 1f) : 0f;
                    Vector4 shape;
                    if (jets)
                    {
                        float y = (Next() - 0.5f) * 0.30f;
                        float w = (Next() - 0.5f) * 0.30f;
                        shape = new Vector4(u, y, w, k == 23 ? 0.33f : 0.17f + Next() * 0.14f);
                    }
                    else if (i == 0)
                    {
                        shape = new Vector4(0f, 0f, 0f, 1.14f);
                    }
                    else
                    {
                        shape = new Vector4(Mathf.Cos(a) * radial * 0.86f, z * 0.72f, Mathf.Sin(a) * radial * 0.86f, 0.72f + Next() * 0.19f);
                    }

                    float first = Next();
                    var data = new Vector4(first, jet, u, Next());
                    lobes.Add(new Lobe(shape, data, !jets || k % 3 == 0 || k == LobesPerJet - 1));
                }
            }
            return lobes;
        }

        private readonly struct Lobe
        {
            public readonly Vector4 Shape;
            public readonly Vector4 Data;
            public readonly bool Glows;

            public Lobe(Vector4 shape, Vector4 data, bool glows)
            {
                Shape = shape;
                Data = data;
                Glows = glows;
            }
        }
    }
}
