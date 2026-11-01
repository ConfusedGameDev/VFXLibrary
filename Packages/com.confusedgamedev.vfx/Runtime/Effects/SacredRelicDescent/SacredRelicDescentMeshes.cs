using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    public static class SacredRelicDescentMeshes
    {
        public const int DebrisCount = 240;
        public const int DustCount = 32;
        public const int SmokeCount = 48;
        public const int MotesCount = 96;

        private const uint Seed = 829652;

        // Holds the widest wave and the relic's start height at full size.
        private static readonly Bounds Bounds = new Bounds(new Vector3(0f, 8f, 0f), new Vector3(60f, 30f, 60f));

        public static Mesh CreateCracks()
        {
            var builder = new VfxMeshBuilder();
            var random = new Stream(Seed);
            AddCracks(builder, random);
            return builder.Build("SacredRelicDescentCracks", Bounds);
        }

        public static Mesh CreateSigil()
        {
            return VfxMeshes.CreateQuads("SacredRelicDescentSigil", 1, Bounds, 4.9f);
        }

        public static Mesh CreateImpact()
        {
            return VfxMeshes.CreateQuads("SacredRelicDescentImpact", 1, Bounds, 10f);
        }

        public static Mesh CreateEcho()
        {
            return Grid("SacredRelicDescentEcho", 128, 4);
        }

        public static Mesh CreateWave()
        {
            return Grid("SacredRelicDescentWave", 160, 16);
        }

        public static Mesh CreateDebris()
        {
            return VfxMeshes.CreateQuads("SacredRelicDescentDebris", DebrisCount, Bounds, seeds: Streams()[0]);
        }

        public static Mesh CreateDust()
        {
            return VfxMeshes.CreateQuads("SacredRelicDescentDust", DustCount, Bounds, seeds: Streams()[1]);
        }

        public static Mesh CreateRelic()
        {
            var vertices = new[] { new Vector3(0f, 0f, 0f), new Vector3(0f, 3f, 1.1316f), new Vector3(-0.98f, 3f, -0.5658f), new Vector3(0.98f, 3f, -0.5658f) };
            int[,] faces = { { 0, 1, 2 }, { 0, 2, 3 }, { 0, 3, 1 }, { 1, 3, 2 } };
            var center = new Vector3(0f, 2.25f, 0f);
            Vector3 light = new Vector3(-0.6f, 1f, 1f).normalized;
            var builder = new VfxMeshBuilder();
            for (int layer = 0; layer < 2; layer++)
            {
                for (int f = 0; f < 4; f++)
                {
                    Vector3 a = vertices[faces[f, 0]];
                    Vector3 b = vertices[faces[f, 1]];
                    Vector3 c = vertices[faces[f, 2]];
                    Vector3 normal = Vector3.Cross(b - a, c - a).normalized;
                    if (Vector3.Dot(normal, (a + b + c) / 3f - center) < 0f)
                    {
                        (b, c) = (c, b);
                        normal = -normal;
                    }

                    float ab = (a - b).magnitude;
                    float bc = (b - c).magnitude;
                    float ca = (c - a).magnitude;
                    float perimeter = ab + bc + ca;
                    Vector3 incenter = (a * bc + b * ca + c * ab) / perimeter;
                    float inradius = Vector3.Cross(b - a, c - a).magnitude / perimeter;
                    float inset = 1f - 0.055f / inradius;
                    float shade = 0.65f + 0.35f * Mathf.Max(0f, Vector3.Dot(normal, light));
                    var data = new Vector4(shade, layer, 0f, 0f);
                    int first = builder.VertexCount;
                    foreach (Vector3 corner in new[] { a, b, c })
                    {
                        // The white panel floats just off the gold shell, which shows as its border.
                        builder.AddVertex(layer == 0 ? corner : (corner - incenter) * inset + incenter + normal * 0.002f, Vector2.zero, data);
                    }

                    builder.AddIndices(first, first + 1, first + 2);
                }
            }
            return builder.Build("SacredRelicDescentRelic", Bounds);
        }

        public static Mesh CreateTrail()
        {
            var builder = new VfxMeshBuilder();
            builder.AddVertex(new Vector3(-0.625f, -3f, 0f), new Vector2(0f, 0f));
            builder.AddVertex(new Vector3(0.625f, -3f, 0f), new Vector2(1f, 0f));
            builder.AddVertex(new Vector3(-0.625f, 3f, 0f), new Vector2(0f, 1f));
            builder.AddVertex(new Vector3(0.625f, 3f, 0f), new Vector2(1f, 1f));
            builder.AddIndices(0, 1, 2, 2, 1, 3);
            return builder.Build("SacredRelicDescentTrail", Bounds);
        }

        public static Mesh CreateSmoke()
        {
            return VfxMeshes.CreateQuads("SacredRelicDescentSmoke", SmokeCount, Bounds, seeds: Streams()[2]);
        }

        public static Mesh CreateMotes()
        {
            return VfxMeshes.CreateQuads("SacredRelicDescentMotes", MotesCount, Bounds, seeds: Streams()[3]);
        }

        /// <summary>The camera-independent layer budget: debris, dust, then motes. The smoke ring is fixed.</summary>
        public static Vector4 LayerCounts(float density)
        {
            return new Vector4(Round(DebrisCount * density), Round(DustCount * density), Round(MotesCount * density), 0f);
        }

        private static float Round(float value)
        {
            return Mathf.Floor(value + 0.5f);
        }

        private static Mesh Grid(string name, int columns, int rows)
        {
            var builder = new VfxMeshBuilder();
            for (int y = 0; y <= rows; y++)
            {
                for (int x = 0; x <= columns; x++)
                {
                    builder.AddVertex(Vector3.zero, new Vector2((float)x / columns, (float)y / rows));
                    if (x < columns && y < rows)
                    {
                        int a = y * (columns + 1) + x;
                        int b = a + columns + 1;
                        builder.AddIndices(a, b, a + 1, a + 1, b, b + 1);
                    }
                }
            }
            return builder.Build(name, Bounds);
        }

        private static void AddFissure(VfxMeshBuilder builder, float x1, float z1, float x2, float z2, float w, float progress)
        {
            float dx = x2 - x1;
            float dz = z2 - z1;
            float length = Mathf.Sqrt(dx * dx + dz * dz);
            float nx = -dz / length * w;
            float nz = dx / length * w;
            int first = builder.VertexCount;
            builder.AddVertex(new Vector3(x1 + nx, 0.025f, z1 + nz), new Vector2(0f, progress));
            builder.AddVertex(new Vector3(x1 - nx, 0.025f, z1 - nz), new Vector2(1f, progress));
            builder.AddVertex(new Vector3(x2 - nx * 0.55f, 0.025f, z2 - nz * 0.55f), new Vector2(1f, progress + 0.15f));
            builder.AddVertex(new Vector3(x2 + nx * 0.55f, 0.025f, z2 + nz * 0.55f), new Vector2(0f, progress + 0.15f));
            builder.AddIndices(first, first + 1, first + 2, first, first + 2, first + 3);
        }

        private static void AddCracks(VfxMeshBuilder builder, Stream random)
        {
            for (int i = 0; i < 13; i++)
            {
                float angle = i * Mathf.PI * 2f / 13f + random.Next() * 0.12f;
                float radius = 0.1f;
                float x = Mathf.Cos(angle) * radius;
                float z = Mathf.Sin(angle) * radius;
                for (int j = 0; j < 6; j++)
                {
                    float nextRadius = radius + 0.2f + random.Next() * 0.3f;
                    float a = angle + (random.Next() - 0.5f) * 0.3f;
                    float nx = Mathf.Cos(a) * nextRadius;
                    float nz = Mathf.Sin(a) * nextRadius;
                    AddFissure(builder, x, z, nx, nz, 0.035f * (1f - j / 8f), j / 7f);
                    if (j == 2 || j == 4)
                    {
                        float branchAngle = a + (random.Next() > 0.5f ? 0.6f : -0.6f);
                        float branchRadius = nextRadius + 0.35f;
                        AddFissure(builder, nx, nz, Mathf.Cos(branchAngle) * branchRadius, Mathf.Sin(branchAngle) * branchRadius, 0.018f, j / 7f + 0.08f);
                    }

                    x = nx;
                    z = nz;
                    radius = nextRadius;
                }
            }
        }

        // The source's one random stream: cracks first, then each layer in turn. Debris only advances it by 48.
        private static Vector4[][] Streams()
        {
            var random = new Stream(Seed);
            AddCracks(new VfxMeshBuilder(), random);
            var result = new[] { Take(random, DebrisCount, 48), Take(random, DustCount, DustCount), Take(random, SmokeCount, SmokeCount), Take(random, MotesCount, MotesCount) };
            for (int i = 0; i < SmokeCount; i++)
            {
                result[2][i].x = (i + 0.5f + (result[2][i].x - 0.5f) * 0.4f) / SmokeCount;
            }
            return result;
        }

        private static Vector4[] Take(Stream random, int count, int streamCount)
        {
            var seeds = new Vector4[count];
            uint following = random.State;
            for (int i = 0; i < count; i++)
            {
                seeds[i] = new Vector4(random.Next(), random.Next(), random.Next(), random.Next());
                if (i == streamCount - 1)
                {
                    following = random.State;
                }
            }

            random.State = following;
            return seeds;
        }

        private sealed class Stream
        {
            public Stream(uint seed)
            {
                State = seed;
            }

            public uint State { get; set; }

            public float Next()
            {
                State = unchecked(State * 1664525u + 1013904223u);
                return (float)(State / 4294967296.0);
            }
        }
    }
}
