using System.Collections.Generic;
using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    public static class GoldenChainRainMeshes
    {
        public const int MaxParticles = 512;

        private const uint Seed = 829647;
        private const int Chains = 36;
        private const int MaxLinks = 72;
        private const int ChipCapacity = 154 * 8;

        // Holds the sources at full size and spread.
        private static readonly Bounds Bounds = new Bounds(new Vector3(0f, 6f, 0f), new Vector3(30f, 16f, 30f));
        private static readonly List<CrackSegment> Segments = CreateSegments();

        private static readonly int[] Maxima = { 512, 154 };
        private static readonly float[] Weights = { 0.5f, 0.3f };

        /// <summary>Instances per layer for a density, split the way the source splits its budget.</summary>
        public static Vector4 LayerCounts(float density)
        {
            return VfxBurstMeshes.LayerCounts(MaxParticles, 0, density, Maxima, Weights);
        }

        public static Mesh CreateCrackGlow()
        {
            var builder = new VfxMeshBuilder();
            var corners = new[] { new Vector2(-1f, -1f), new Vector2(1f, -1f), new Vector2(-1f, 1f), new Vector2(-1f, 1f), new Vector2(1f, -1f), new Vector2(1f, 1f) };
            for (int chain = 0; chain < Chains; chain++)
            {
                foreach (CrackSegment segment in Segments)
                {
                    for (int i = 0; i < 6; i++)
                    {
                        builder.AddVertex(corners[i], segment.B, new Vector4(segment.A.x, segment.A.y, segment.RevealA, chain), segment.RevealB);
                        builder.AddIndices(builder.VertexCount - 1);
                    }
                }
            }
            return builder.Build("GoldenChainRainCrackGlow", Bounds);
        }

        public static Mesh CreateCracks()
        {
            var builder = new VfxMeshBuilder();
            for (int chain = 0; chain < Chains; chain++)
            {
                var data = new Vector4(chain, 0f, 0f, 0f);
                foreach (CrackSegment segment in Segments)
                {
                    Vector2 d = segment.B - segment.A;
                    var n = new Vector2(-d.y, d.x) / d.magnitude;
                    Vector2 a = segment.A + n * segment.Width;
                    Vector2 b = segment.A - n * segment.Width;
                    Vector2 c = segment.B + n * segment.Width * 0.55f;
                    Vector2 e = segment.B - n * segment.Width * 0.55f;
                    int first = builder.VertexCount;
                    builder.AddVertex(new Vector3(a.x, 0.012f, a.y), new Vector2(-1f, segment.RevealA), data);
                    builder.AddVertex(new Vector3(b.x, 0.012f, b.y), new Vector2(1f, segment.RevealA), data);
                    builder.AddVertex(new Vector3(c.x, 0.012f, c.y), new Vector2(-1f, segment.RevealB), data);
                    builder.AddVertex(new Vector3(e.x, 0.012f, e.y), new Vector2(1f, segment.RevealB), data);
                    builder.AddIndices(first, first + 2, first + 1, first + 1, first + 2, first + 3);
                }
            }
            return builder.Build("GoldenChainRainCracks", Bounds);
        }

        public static Mesh CreateBody()
        {
            return CreateChain("GoldenChainRainBody");
        }

        public static Mesh CreateHalo()
        {
            return CreateChain("GoldenChainRainHalo");
        }

        public static Mesh CreateArrowheads()
        {
            var builder = new VfxMeshBuilder();
            for (int chain = 0; chain < Chains; chain++)
            {
                var data = new Vector4(chain, 0f, 0f, 0f);
                for (int i = 0; i < 4; i++)
                {
                    float u0 = i / 4f;
                    float u1 = (i + 1) / 4f;
                    Vector3 a = ConeRim(u0);
                    Vector3 b = ConeRim(u1);
                    builder.AddFlatTriangle(a, b, new Vector3(0f, 0.32f, 0f), new Vector2(u0, 0f), new Vector2(u1, 0f), new Vector2(u1, 1f), data);
                    builder.AddFlatTriangle(b, a, new Vector3(0f, -0.32f, 0f), CapUv(u1), CapUv(u0), new Vector2(0.5f, 0.5f), data);
                }
            }
            return builder.Build("GoldenChainRainArrowheads", Bounds);
        }

        public static Mesh CreateRipples()
        {
            return VfxMeshes.CreateQuads("GoldenChainRainRipples", Chains, Bounds, 2f);
        }

        public static Mesh CreateFeather()
        {
            return VfxMeshes.CreateQuads("GoldenChainRainFeather", Chains, Bounds, 2f);
        }

        public static Mesh CreateBloom()
        {
            return VfxMeshes.CreateQuads("GoldenChainRainBloom", Chains, Bounds, 2f);
        }

        public static Mesh CreateMotes()
        {
            return VfxMeshes.CreateQuads("GoldenChainRainMotes", MaxParticles, Bounds, seeds: VfxMeshes.CreateSeeds(MaxParticles, Seed, 0));
        }

        public static Mesh CreateChips()
        {
            Vector4[] seeds = VfxMeshes.CreateSeeds(ChipCapacity, Seed, 1);
            Mesh mesh = VfxMeshes.CreateQuads("GoldenChainRainChips", ChipCapacity, Bounds, seeds: seeds);
            var a = new List<Vector3>(ChipCapacity * 4);
            var b = new List<Vector3>(ChipCapacity * 4);
            foreach (Vector4 seed in seeds)
            {
                CrackSegment segment = Segments[Mathf.Min(Segments.Count - 1, Mathf.FloorToInt(seed.y * Segments.Count))];
                for (int v = 0; v < 4; v++)
                {
                    a.Add(new Vector3(segment.A.x, segment.A.y, segment.RevealA));
                    b.Add(new Vector3(segment.B.x, segment.B.y, segment.RevealB));
                }
            }
            mesh.SetUVs(3, a);
            mesh.SetUVs(4, b);
            return mesh;
        }

        private static Mesh CreateChain(string name)
        {
            var builder = new VfxMeshBuilder();
            for (int chain = 0; chain < Chains; chain++)
            {
                for (int link = 0; link < MaxLinks; link++)
                {
                    var data = new Vector4(chain, link, 0f, 0f);
                    int first = builder.VertexCount;
                    builder.AddVertex(new Vector3(-0.16f, -0.24f, 0f), new Vector2(0f, 0f), data);
                    builder.AddVertex(new Vector3(0.16f, -0.24f, 0f), new Vector2(1f, 0f), data);
                    builder.AddVertex(new Vector3(-0.16f, 0.24f, 0f), new Vector2(0f, 1f), data);
                    builder.AddVertex(new Vector3(0.16f, 0.24f, 0f), new Vector2(1f, 1f), data);
                    builder.AddIndices(first, first + 1, first + 2, first + 2, first + 1, first + 3);
                }
            }
            return builder.Build(name, Bounds);
        }

        private static Vector3 ConeRim(float u)
        {
            float a = u * Mathf.PI * 2f;
            return new Vector3(Mathf.Sin(a) * 0.22f, -0.32f, Mathf.Cos(a) * 0.22f);
        }

        private static Vector2 CapUv(float u)
        {
            float a = u * Mathf.PI * 2f;
            return new Vector2(Mathf.Cos(a) * 0.5f + 0.5f, Mathf.Sin(a) * -0.5f + 0.5f);
        }

        // One branched pattern, shared by every landing.
        private static List<CrackSegment> CreateSegments()
        {
            var segments = new List<CrackSegment>();
            uint state = 0x63ab91;
            float Next()
            {
                state = unchecked(state * 1664525u + 1013904223u);
                return (float)(state / 4294967296.0);
            }

            for (int ray = 0; ray < 8; ray++)
            {
                float angle = ray * Mathf.PI / 4f + (Next() - 0.5f) * 0.34f;
                float reach = 0.78f + Next() * 0.22f;
                Vector2 previous = Vector2.zero;
                for (int segment = 1; segment <= 6; segment++)
                {
                    float radius = segment / 6f * reach;
                    float turn = angle + (Next() - 0.5f) * 0.35f;
                    var next = new Vector2(Mathf.Cos(turn) * radius, Mathf.Sin(turn) * radius);
                    segments.Add(new CrackSegment(previous, next, 0.034f * (1f - segment / 8f), (segment - 1) / 6f, segment / 6f));
                    if (segment == 2 || segment == 4)
                    {
                        float fork = turn + (Next() > 0.5f ? 1f : -1f) * (0.45f + Next() * 0.5f);
                        float length = 0.12f + Next() * 0.13f;
                        var end = new Vector2(next.x + Mathf.Cos(fork) * length, next.y + Mathf.Sin(fork) * length);
                        segments.Add(new CrackSegment(next, end, 0.012f, segment / 6f, Mathf.Min(1f, segment / 6f + 0.22f)));
                    }

                    previous = next;
                }
            }
            return segments;
        }

        private readonly struct CrackSegment
        {
            public readonly Vector2 A;
            public readonly Vector2 B;
            public readonly float Width;
            public readonly float RevealA;
            public readonly float RevealB;

            public CrackSegment(Vector2 a, Vector2 b, float width, float revealA, float revealB)
            {
                A = a;
                B = b;
                Width = width;
                RevealA = revealA;
                RevealB = revealB;
            }
        }
    }
}
