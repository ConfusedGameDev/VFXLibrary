using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    public static class IceShardMeshes
    {
        public const int MaxParticles = 512;

        private const uint Seed = 27561;

        private static readonly Bounds EffectBounds = VfxMeshes.ProjectileBounds;

        // length, radius, x, y, z, tilt, spin
        private static readonly float[][] Crystals =
        {
            new[] { 0.85f, 0.23f, 0.08f, 0f, 0f, 0f, 0.2f },
            new[] { 0.65f, 0.15f, -0.30f, 0.23f, 0.08f, -0.27f, 0.8f },
            new[] { 0.49f, 0.13f, -0.46f, -0.17f, 0.17f, 0.35f, 2.0f },
            new[] { 0.58f, 0.14f, -0.36f, -0.03f, -0.24f, 0.16f, 4.1f },
            new[] { 0.30f, 0.10f, -0.62f, 0.20f, -0.16f, -0.5f, 1.6f }
        };

        // angle, length, radius, phase
        private static readonly Vector4[] StreamPaths =
        {
            new Vector4(0.5f, 2.6f, 0.34f, 0.3f),
            new Vector4(2.7f, 2.0f, 0.40f, 1.7f),
            new Vector4(4.8f, 2.35f, 0.28f, 3.2f)
        };

        /// <summary>Five six-sided lances. Every triangle has its own vertices, so the facets stay flat.</summary>
        public static Mesh CreateCore()
        {
            var builder = new VfxMeshBuilder();
            foreach (float[] crystal in Crystals)
            {
                AddLance(builder, crystal);
            }
            builder.ComputeNormals();
            return builder.Build("IceShardCore", EffectBounds);
        }

        public static Mesh CreateTrails()
        {
            var builder = new VfxMeshBuilder();
            foreach (Vector4 path in StreamPaths)
            {
                builder.AddTube(24, 5, (h, v) => new Vector3(h, Mathf.Cos(v * Mathf.PI * 2f), Mathf.Sin(v * Mathf.PI * 2f)), path);
            }
            return builder.Build("IceShardTrails", EffectBounds);
        }

        public static Mesh CreateParticles()
        {
            var shape = new VfxMeshBuilder();
            shape.AddOctahedron(0.7f);
            return VfxMeshBuilder.Instance("IceShardParticles", shape, VfxMeshes.CreateSeeds(MaxParticles, Seed), EffectBounds);
        }

        /// <summary>Thirteen small crystals around the contact, each spinning about its centre.</summary>
        public static Mesh CreateImpact()
        {
            var builder = new VfxMeshBuilder();
            for (int i = 0; i < 13; i++)
            {
                float a = i * 2.39996f;
                float r = 0.15f + (i * 7 % 13) / 13f * 0.45f;
                builder.AddCrystal(new Vector3(0.08f + (i * 5 % 13) / 13f * 0.7f, Mathf.Cos(a) * r, Mathf.Sin(a) * r), i, 0.28f + i % 4 * 0.12f, 0.09f + i % 3 * 0.018f);
            }
            return builder.Build("IceShardImpact", EffectBounds);
        }

        public static Mesh CreateGlow()
        {
            return VfxMeshes.CreateQuads("IceShardGlow", 1, EffectBounds, 1.8f);
        }

        private static void AddLance(VfxMeshBuilder builder, float[] crystal)
        {
            const int Sides = 6;
            const int Steps = 2;
            float length = crystal[0];
            float radius = crystal[1];
            var offset = new Vector3(crystal[2], crystal[3], crystal[4]);
            float tilt = crystal[5];
            float spin = crystal[6];

            Vector3 Point(int step, int side)
            {
                float h = (float)step / Steps;
                float profile = Mathf.Pow(Mathf.Max(0f, Mathf.Sin(h * Mathf.PI)), 0.9f) * (0.65f + 0.35f * h);
                float a = (float)side / Sides * Mathf.PI * 2f;
                float uneven = 1f + 0.13f * Mathf.Sin(a * 3f + 0.8f);
                var p = new Vector3((h * 2f - 1f) * length, Mathf.Cos(a) * radius * profile * uneven, Mathf.Sin(a) * radius * profile);

                p = new Vector3(p.x, p.y * Mathf.Cos(spin) - p.z * Mathf.Sin(spin), p.y * Mathf.Sin(spin) + p.z * Mathf.Cos(spin));
                p = new Vector3(p.x * Mathf.Cos(tilt) - p.y * Mathf.Sin(tilt), p.x * Mathf.Sin(tilt) + p.y * Mathf.Cos(tilt), p.z);
                return p + offset;
            }

            void Corner(int step, int side)
            {
                builder.AddVertex(Point(step, side), new Vector2((float)step / Steps, (float)side / Sides));
            }

            for (int step = 0; step < Steps; step++)
            {
                for (int side = 0; side < Sides; side++)
                {
                    int first = builder.VertexCount;
                    Corner(step, side);
                    Corner(step, side + 1);
                    Corner(step + 1, side);
                    Corner(step, side + 1);
                    Corner(step + 1, side + 1);
                    Corner(step + 1, side);
                    builder.AddIndices(first, first + 1, first + 2, first + 3, first + 4, first + 5);
                }
            }
        }
    }
}
