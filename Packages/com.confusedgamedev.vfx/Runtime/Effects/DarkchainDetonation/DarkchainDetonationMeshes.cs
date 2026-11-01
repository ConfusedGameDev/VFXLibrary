using System.Collections.Generic;
using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    public static class DarkchainDetonationMeshes
    {
        public const int MaxParticles = 384;

        private const uint Seed = 829645;

        private static readonly int[] Maxima = { 256, 128 };
        private static readonly float[] Weights = { 2f / 3f, 1f / 3f };

        /// <summary>Instances per layer for a density, split the way the source splits its budget.</summary>
        public static Vector4 LayerCounts(float density)
        {
            return VfxBurstMeshes.LayerCounts(MaxParticles, 0, density, Maxima, Weights);
        }

        public static Mesh CreateSigil0()
        {
            return Plane("DarkchainSigil0", 2f);
        }

        public static Mesh CreateSigil1()
        {
            return Plane("DarkchainSigil1", 2f);
        }

        public static Mesh CreateChainBody()
        {
            return CreateLinks("DarkchainChainBody");
        }

        public static Mesh CreateChainGlow()
        {
            return CreateLinks("DarkchainChainGlow");
        }

        public static Mesh CreateRootSeals()
        {
            return CreateSeals();
        }

        public static Mesh CreateOrbBody()
        {
            var builder = new VfxMeshBuilder();
            builder.AddSphere(96, 40, Vector3.one);
            return builder.Build("DarkchainOrbBody", EffectBounds);
        }

        public static Mesh CreateOrbHalo()
        {
            return Plane("DarkchainOrbHalo", 1f);
        }

        public static Mesh CreateOrbArcs()
        {
            return CreateForks("DarkchainOrbArcs", 6, 12);
        }

        public static Mesh CreateFieldLightning()
        {
            return CreateForks("DarkchainFieldLightning", 36, 20);
        }

        public static Mesh CreateBlackAura()
        {
            return Instance("DarkchainBlackAura", Grid(24, 1), 16, InkSeeds(16, 0x391b47u));
        }

        public static Mesh CreateInwardRibbons()
        {
            return Instance("DarkchainInwardRibbons", Grid(32, 1), 12, InkSeeds(12, 0x7a23d1u));
        }

        public static Mesh CreateInwardParticles()
        {
            return CreateShards("DarkchainInwardParticles", 256, 0);
        }

        public static Mesh CreateDebris()
        {
            return CreateShards("DarkchainDebris", 128, 1);
        }

        public static Mesh CreateBlastInk()
        {
            return CreateBlast("DarkchainBlastInk");
        }

        public static Mesh CreateBlast()
        {
            return CreateBlast("DarkchainBlast");
        }

        public static Mesh CreateEnergySurface()
        {
            return CreatePressure("DarkchainEnergySurface");
        }

        public static Mesh CreateEnergyGlow()
        {
            return CreatePressure("DarkchainEnergyGlow");
        }

        public static Mesh CreateCoreEjection()
        {
            return CreateEjection();
        }

        public static Mesh CreateReleasePlasma()
        {
            var builder = new VfxMeshBuilder();
            builder.AddSphere(24, 16, Vector3.one);
            return builder.Build("DarkchainReleasePlasma", EffectBounds);
        }

        public static Mesh CreateImpactGlints()
        {
            return CreateGlints();
        }

        public static Mesh CreateAfterSmoke()
        {
            return Instance("DarkchainAfterSmoke", Grid(1, 1), 24, InkSeeds(24, 0x7a23d1u));
        }

        public static Mesh CreateRefraction()
        {
            return Plane("DarkchainRefraction", 1f);
        }

        public static Mesh CreateShockRing()
        {
            return CreateRing();
        }

        public static Mesh CreateGroundSmoke()
        {
            return CreateGround("DarkchainGroundSmoke", Grid(1, 1));
        }

        public static Mesh CreateSmokeTails()
        {
            return CreateGround("DarkchainSmokeTails", TailCards());
        }

        private const int Chains = 12;
        private const int MaxLinks = 48;
        private const int BlastPieces = 252;
        private const float LowerRadius = 2.3f;
        private const float UpperRadius = 6.21f;
        private const float BaseY = 0.04f;
        private const float Height = 4.4f;
        private const float CenterY = 2.24f;
        private const float Burst = DarkchainMotion.Burst;
        private const float ReleaseRadius = 1.45f;
        private const float BlastRadius = 4.2f;
        private const float BlastExpand = 0.08f;
        private const float BreakTravel = 0.12f;
        private const float WaveRadius = 10.6f;
        private const float WaveWidth = 4.3f;
        private const float WaveHeight = 0.18f;

        // Holds the ink's widest orbit, the shock ring and the debris at size 2.
        private static readonly Bounds EffectBounds = new Bounds(new Vector3(0f, 4f, 0f), new Vector3(52f, 52f, 52f));

        private sealed class Chain
        {
            public int tier;
            public float angle;
            public float phase;
            public Vector3 start;
            public Vector3 end;
            public float length;
            public int count;
            public float pitch;
            public float impactU;
            public float impactTime;
            public readonly List<Vector4> fragments = new List<Vector4>();
        }

        private sealed class Shape
        {
            public Vector3[] positions;
            public Vector2[] uvs;
            public int[] indices;
        }

        private sealed class Random
        {
            private uint state;

            public Random(uint seed)
            {
                state = seed;
            }

            public float Next()
            {
                state = unchecked(state * 1664525u + 1013904223u);
                return (float)(state / 4294967296.0);
            }
        }

        /// <summary>Links baked for the source's layout, for tests and tools.</summary>
        public static int LinkCount()
        {
            int total = 0;
            foreach (Chain chain in Layout())
            {
                total += chain.count;
            }
            return total;
        }

        // The strands' anchors, then the chunks each one breaks into.
        private static List<Chain> Layout()
        {
            var random = new Random(Seed);
            var chains = new List<Chain>();
            const float Tau = Mathf.PI * 2f;
            for (int i = 0; i < Chains; i++)
            {
                float angle = (i + 0.5f) * Tau / Chains + (random.Next() - 0.5f) * 0.08f;
                int tier = i % 2;
                float sourceRadius = tier == 1 ? UpperRadius : LowerRadius;
                float targetRadius = tier == 1 ? LowerRadius : UpperRadius;
                float rootRadius = Mathf.Sqrt(0.04f + random.Next() * (0.82f * 0.82f - 0.04f)) * sourceRadius;
                float endAngle = angle + (random.Next() - 0.5f) * 0.10f;
                float endRadius = Mathf.Sqrt(0.04f + random.Next() * (0.82f * 0.82f - 0.04f)) * targetRadius;
                var chain = new Chain
                {
                    tier = tier,
                    angle = angle,
                    phase = random.Next() * Tau,
                    start = new Vector3(0f, BaseY + tier * Height, 0f),
                    end = new Vector3(0f, BaseY + (1 - tier) * Height, 0f)
                };

                // A straight strand stays clear of the orb by moving its anchors inside the sigils.
                for (int attempt = 0; attempt <= 20; attempt++)
                {
                    float blend = attempt / 20f;
                    float r0 = rootRadius + (0.82f * sourceRadius - rootRadius) * blend;
                    float r1 = endRadius + (0.82f * targetRadius - endRadius) * blend;
                    chain.start.x = Mathf.Cos(angle) * r0;
                    chain.start.z = Mathf.Sin(angle) * r0;
                    chain.end.x = Mathf.Cos(endAngle) * r1;
                    chain.end.z = Mathf.Sin(endAngle) * r1;
                    Vector3 d = chain.end - chain.start;
                    Vector3 fromCenter = chain.start - new Vector3(0f, CenterY, 0f);
                    float u = Mathf.Clamp01(-Vector3.Dot(fromCenter, d) / d.sqrMagnitude);
                    if ((fromCenter + d * u).magnitude >= 1.98f)
                    {
                        break;
                    }
                }

                Vector3 delta = chain.end - chain.start;
                chain.length = delta.magnitude;
                chain.count = Mathf.Min(MaxLinks, Mathf.Max(16, Mathf.CeilToInt(chain.length / 0.18f) + 1));
                chain.pitch = chain.length / (chain.count - 1);
                Vector3 offset = chain.start - new Vector3(0f, CenterY, 0f);
                chain.impactU = Mathf.Clamp01(-Vector3.Dot(offset, delta) / (chain.length * chain.length));
                float distance = (offset + delta * chain.impactU).magnitude;
                float fraction = Mathf.Clamp01((distance - ReleaseRadius) / (BlastRadius - ReleaseRadius));
                chain.impactTime = Burst + BlastExpand * (1f - Mathf.Pow(1f - fraction, 1f / 3f));
                chains.Add(chain);
            }

            int[] sizes = { 1, 2, 3, 5 };
            float[] scales = { 0.55f, 0.75f, 1f, 1.25f, 1.5f };
            foreach (Chain chain in chains)
            {
                for (int first = 0; first < chain.count;)
                {
                    int count = Mathf.Min(chain.count - first, sizes[Mathf.FloorToInt(random.Next() * 4f)]);
                    float scale = scales[Mathf.FloorToInt(random.Next() * 5f)];
                    chain.fragments.Add(new Vector4(first, count, (first + (count - 1) * 0.5f) / (chain.count - 1), scale));
                    first += count;
                }
            }
            return chains;
        }

        private static float BreakTime(Chain chain, float u)
        {
            return chain.impactTime + Mathf.Abs(u - chain.impactU) / Mathf.Max(chain.impactU, 1f - chain.impactU) * BreakTravel;
        }

        private static Mesh CreateLinks(string name)
        {
            var link = new List<Vector4>();
            var brk = new List<Vector4>();
            var start = new List<Vector4>();
            var finish = new List<Vector4>();
            var shock = new List<Vector4>();
            foreach (Chain chain in Layout())
            {
                for (int piece = 0; piece < chain.fragments.Count; piece++)
                {
                    Vector4 fragment = chain.fragments[piece];
                    int first = (int)fragment.x;
                    for (int j = first; j < first + (int)fragment.y; j++)
                    {
                        link.Add(new Vector4(j / (chain.count - 1f), j, chain.pitch / 0.18f, chain.angle));
                        brk.Add(new Vector4(fragment.z, piece, chain.phase, fragment.w));
                        start.Add(new Vector4(chain.start.x, chain.start.y, chain.start.z, chain.phase));
                        finish.Add(chain.end);
                        shock.Add(new Vector3(chain.impactU, chain.impactTime, Mathf.Max(chain.impactU, 1f - chain.impactU)));
                    }
                }
            }
            return Instance(name, Grid(1, 1), link.Count, link.ToArray(), brk.ToArray(), start.ToArray(), finish.ToArray(), shock.ToArray());
        }

        private static Mesh CreateSeals()
        {
            List<Chain> layout = Layout();
            var anchors = new Vector4[layout.Count * 2];
            var releases = new Vector4[layout.Count * 2];
            for (int i = 0; i < layout.Count; i++)
            {
                Chain chain = layout[i];
                Vector4 head = chain.fragments[0];
                Vector4 tail = chain.fragments[chain.fragments.Count - 1];
                anchors[i * 2] = new Vector4(chain.start.x, chain.start.y, chain.start.z, 0f);
                anchors[i * 2 + 1] = new Vector4(chain.end.x, chain.end.y, chain.end.z, 1f);
                releases[i * 2] = new Vector4(BreakTime(chain, head.z), 0f, 0f, 0f);
                releases[i * 2 + 1] = new Vector4(BreakTime(chain, tail.z), 0f, 0f, 0f);
            }
            return Instance("DarkchainRootSeals", Grid(1, 1), anchors.Length, anchors, releases);
        }

        // A strand and its fork for each slot.
        private static Mesh CreateForks(string name, int slots, int segments)
        {
            var values = new Vector4[slots * 2];
            for (int i = 0; i < slots; i++)
            {
                values[i * 2] = new Vector4(i, 0f, 0f, 0f);
                values[i * 2 + 1] = new Vector4(i, 1f, 0f, 0f);
            }
            return Instance(name, Grid(segments, 1), values.Length, values);
        }

        private static Vector4[] InkSeeds(int count, uint mask)
        {
            var random = new Random(Seed ^ mask);
            var seeds = new Vector4[count];
            for (int i = 0; i < count; i++)
            {
                float x = (i + random.Next() * 0.65f) / count;
                float y = random.Next();
                float z = random.Next();
                seeds[i] = new Vector4(x, y, z, random.Next());
            }
            return seeds;
        }

        private static Mesh CreateShards(string name, int count, int layerIndex)
        {
            var ids = new Vector4[count];
            for (int i = 0; i < count; i++)
            {
                ids[i] = new Vector4(i, 0f, 0f, 0f);
            }
            return Instance(name, Grid(1, 1), count, VfxMeshes.CreateSeeds(count, Seed, layerIndex), ids);
        }

        private static Mesh CreateBlast(string name)
        {
            var directions = new Vector4[BlastPieces];
            var shapes = new Vector4[BlastPieces];
            var strengths = new Vector4[BlastPieces];
            for (int i = 0; i < BlastPieces; i++)
            {
                float seed = (i * 17 % 29) / 29f;
                float y = 1f - 2f * (i + 0.5f) / BlastPieces;
                float angle = (float)(i * 2.399963229728653 + Seed * 0.001);
                float r = Mathf.Sqrt(1f - y * y);
                directions[i] = new Vector4(Mathf.Cos(angle) * r, y, Mathf.Sin(angle) * r, seed);
                bool primary = i % 28 % 5 == 0;
                strengths[i] = new Vector4(primary ? 1f : 0.35f + seed * 0.15f, 0f, 0f, 0f);
                shapes[i] = new Vector4((primary ? 3.4f + seed * 0.3f : 2f + seed * 0.7f) * 0.2f, (primary ? 0.38f + seed * 0.06f : 0.12f + seed * 0.06f) * 0.25f, i * 1.73f, (i % 2 == 1 ? 1f : -1f) * (0.8f + seed));
            }
            return Instance(name, Grid(1, 32), BlastPieces, directions, shapes, strengths);
        }

        private static Mesh CreatePressure(string name)
        {
            float[] arc = { 128f, 106f, 140f, 116f };
            float[] depth = { 30f, 23f, 35f, 26f };
            var turns = new[] { new Vector3(0.42f, 0.15f, -0.55f), new Vector3(-0.72f, 1.82f, 0.32f), new Vector3(1.14f, 3.75f, -0.28f), new Vector3(-0.24f, 5.16f, 1.03f) };
            var shapes = new Vector4[4];
            var rotations = new Vector4[4];
            for (int i = 0; i < 4; i++)
            {
                shapes[i] = new Vector4(i % 2 == 1 ? 0.12f : -0.15f, arc[i] * Mathf.Deg2Rad, depth[i] * Mathf.Deg2Rad, i * 0.006f);
                rotations[i] = EulerXyz(turns[i]);
            }
            return Instance(name, Grid(32, 8), 4, shapes, rotations);
        }

        // The source's quaternion, in its own right-handed axes.
        private static Vector4 EulerXyz(Vector3 e)
        {
            float c1 = Mathf.Cos(e.x / 2f);
            float c2 = Mathf.Cos(e.y / 2f);
            float c3 = Mathf.Cos(e.z / 2f);
            float s1 = Mathf.Sin(e.x / 2f);
            float s2 = Mathf.Sin(e.y / 2f);
            float s3 = Mathf.Sin(e.z / 2f);
            return new Vector4(s1 * c2 * c3 + c1 * s2 * s3, c1 * s2 * c3 - s1 * c2 * s3, c1 * c2 * s3 + s1 * s2 * c3, c1 * c2 * c3 - s1 * s2 * s3);
        }

        private static Mesh CreateEjection()
        {
            var directions = new Vector4[32];
            var seeds = new Vector4[32];
            for (int i = 0; i < 32; i++)
            {
                float seed = (Seed + i * 43) % 127 / 127f;
                float y = 1f - 2f * (i + 0.5f) / 32f;
                float a = i * 2.39996323f + seed * 0.24f;
                float r = Mathf.Sqrt(1f - y * y);
                directions[i] = new Vector4(Mathf.Cos(a) * r, y, Mathf.Sin(a) * r, 2.7f + seed * 2f);
                seeds[i] = new Vector4(seed, i % 5 == 0 ? 0.46f : 0.10f + seed * 0.09f, i % 3 * 0.004f, i % 5 == 0 ? 1f : 0.65f);
            }
            return Instance("DarkchainCoreEjection", Grid(12, 1), 32, directions, seeds);
        }

        private static Mesh CreateGlints()
        {
            var glints = new Vector4[20];
            for (int j = 0; j < 20; j++)
            {
                glints[j] = new Vector4(j, (Seed + j * 31) % 113 / 113f, (Seed + j * 67) % 127 / 127f, (Seed + j * 17) % 97 / 97f);
            }
            return Instance("DarkchainImpactGlints", Grid(1, 1), 20, glints);
        }

        // A shallow sheet, whose section the vertex shader stretches as the wave runs out.
        private static Mesh CreateRing()
        {
            const int Segments = 160;
            float[,] section = { { 0f, -0.5f }, { 0f, 0.5f }, { 0.24f, 0.5f }, { 1f, 0f }, { 0.24f, -0.5f }, { 0f, -0.5f } };
            int span = section.GetLength(0);
            var builder = new VfxMeshBuilder();
            for (int i = 0; i <= Segments; i++)
            {
                float angle = i / (float)Segments * Mathf.PI * 2f;
                for (int j = 0; j < span; j++)
                {
                    float q = section[j, 0];
                    float h = section[j, 1];
                    float r = WaveRadius - WaveWidth * (1f - q);
                    builder.AddVertex(new Vector3(Mathf.Cos(angle) * r, CenterY + h * WaveHeight, Mathf.Sin(angle) * r), new Vector2(q, h));
                }
            }

            for (int i = 0; i < Segments; i++)
            {
                for (int j = 0; j < span - 1; j++)
                {
                    int a = i * span + j;
                    int b = a + span;
                    builder.AddIndices(a, b, a + 1, b, b + 1, a + 1);
                }
            }
            return builder.Build("DarkchainShockRing", EffectBounds);
        }

        private static Mesh CreateGround(string name, Shape shape)
        {
            var random = new Random(Seed ^ 0x639ac1u);
            var route0 = new Vector4[6];
            var route1 = new Vector4[6];
            var route2 = new Vector4[6];
            var timing = new Vector4[6];
            for (int i = 0; i < 6; i++)
            {
                float angle = i * Mathf.PI / 3f;
                const float Radius = 8f;
                const float Y = 0.15f;
                float bend = 0.75f + random.Next() * 0.35f;
                route0[i] = new Vector3(Mathf.Cos(angle) * Radius, Y, Mathf.Sin(angle) * Radius);
                route1[i] = new Vector3(Mathf.Cos(angle + bend) * Radius * 0.86f, Y, Mathf.Sin(angle + bend) * Radius * 0.86f);
                route2[i] = new Vector3(Mathf.Cos(angle + bend * 1.35f) * 1.2f, Y, Mathf.Sin(angle + bend * 1.35f) * 1.2f);
                timing[i] = new Vector4(0f, 1.15f + random.Next() * 0.30f, 0f, 0f);
                timing[i].z = timing[i].y;
            }

            for (int i = 0; i < 6; i++)
            {
                timing[i].w = 0.65f + random.Next() * 0.35f;
            }
            return Instance(name, shape, 6, route0, route1, route2, timing);
        }

        // Eight overlapping cards a trail. Each card's place along the trail is in z.
        private static Shape TailCards()
        {
            var positions = new List<Vector3>();
            var uvs = new List<Vector2>();
            var indices = new List<int>();
            for (int i = 0; i < 8; i++)
            {
                int first = i * 4;
                float place = i / 7f;
                positions.Add(new Vector3(-0.5f, -0.5f, place));
                positions.Add(new Vector3(0.5f, -0.5f, place));
                positions.Add(new Vector3(0.5f, 0.5f, place));
                positions.Add(new Vector3(-0.5f, 0.5f, place));
                uvs.Add(new Vector2(0f, 0f));
                uvs.Add(new Vector2(1f, 0f));
                uvs.Add(new Vector2(1f, 1f));
                uvs.Add(new Vector2(0f, 1f));
                indices.AddRange(new[] { first, first + 1, first + 2, first, first + 2, first + 3 });
            }
            return new Shape { positions = positions.ToArray(), uvs = uvs.ToArray(), indices = indices.ToArray() };
        }

        // The source's PlaneGeometry(1, 1, columns, rows).
        private static Shape Grid(int columns, int rows)
        {
            var positions = new List<Vector3>();
            var uvs = new List<Vector2>();
            var indices = new List<int>();
            for (int y = 0; y <= rows; y++)
            {
                for (int x = 0; x <= columns; x++)
                {
                    float u = (float)x / columns;
                    float v = (float)y / rows;
                    positions.Add(new Vector3(u - 0.5f, 0.5f - v, 0f));
                    uvs.Add(new Vector2(u, 1f - v));
                }
            }

            for (int y = 0; y < rows; y++)
            {
                for (int x = 0; x < columns; x++)
                {
                    int a = x + (columns + 1) * y;
                    int b = x + (columns + 1) * (y + 1);
                    int c = x + 1 + (columns + 1) * (y + 1);
                    int d = x + 1 + (columns + 1) * y;
                    indices.AddRange(new[] { a, b, d, b, c, d });
                }
            }
            return new Shape { positions = positions.ToArray(), uvs = uvs.ToArray(), indices = indices.ToArray() };
        }

        private static Mesh Plane(string name, float width)
        {
            Shape shape = Grid(1, 1);
            for (int i = 0; i < shape.positions.Length; i++)
            {
                shape.positions[i] *= width;
            }
            return Instance(name, shape, 1);
        }

        // Instances baked into one mesh. Each attribute goes in its own UV channel, from UV1.
        private static Mesh Instance(string name, Shape shape, int count, params Vector4[][] attributes)
        {
            var positions = new List<Vector3>(count * shape.positions.Length);
            var uvs = new List<Vector2>(count * shape.positions.Length);
            var channels = new List<Vector4>[attributes.Length];
            for (int k = 0; k < channels.Length; k++)
            {
                channels[k] = new List<Vector4>(count * shape.positions.Length);
            }

            var indices = new List<int>(count * shape.indices.Length);
            for (int i = 0; i < count; i++)
            {
                int first = positions.Count;
                positions.AddRange(shape.positions);
                uvs.AddRange(shape.uvs);
                for (int k = 0; k < channels.Length; k++)
                {
                    for (int v = 0; v < shape.positions.Length; v++)
                    {
                        channels[k].Add(attributes[k][i]);
                    }
                }

                foreach (int index in shape.indices)
                {
                    indices.Add(first + index);
                }
            }

            var mesh = new Mesh { name = name, indexFormat = UnityEngine.Rendering.IndexFormat.UInt32 };
            mesh.SetVertices(positions);
            mesh.SetUVs(0, uvs);
            for (int k = 0; k < channels.Length; k++)
            {
                mesh.SetUVs(k + 1, channels[k]);
            }
            mesh.SetTriangles(indices, 0);
            mesh.bounds = EffectBounds;
            return mesh;
        }
    }
}
