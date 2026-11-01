using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    public static class MagmaFissureMeshes
    {
        public const int MaxParticles = 512;

        private const uint Seed = 358293;

        private static readonly int[] Maxima = { 512 };
        private static readonly float[] Weights = { 1f };

        /// <summary>Instances per layer for a density, split the way the source splits its budget.</summary>
        public static Vector4 LayerCounts(float density)
        {
            return VfxBurstMeshes.LayerCounts(MaxParticles, 0, density, Maxima, Weights);
        }

        public static Mesh CreateBody()
        {
            var builder = new VfxMeshBuilder();
            for (int i = 0; i < 13; i++)
            {
                float x = -2.25f + i * 0.36f;
                float z = Wander(i);
                var from = new Vector3(x, 0.016f, z);
                var to = new Vector3(x + 0.37f, 0.016f, Wander(i + 1));
                AddSegment(builder, from, to, 0.038f + i % 3 * 0.007f, new Vector4(i / 12f, 0f, 0f, 0.8f));
                for (int side = -1; side <= 1; side += 2)
                {
                    int salt = i * 2 + (side == 1 ? 1 : 0);
                    float jitter = Mathf.Sin(salt * 7.3f) * 0.11f;
                    AddRock(builder, i, side);
                    if ((i + side) % 3 != 0)
                    {
                        var root = new Vector3(x, 0.033f, z);
                        var tip = new Vector3(0.10f + jitter, 0.026f, side * (0.30f + salt % 4 * 0.12f));
                        AddSegment(builder, root, root + tip, 0.018f, new Vector4(i / 12f, side, 2f, 0.65f));
                        if (i % 2 == 0)
                        {
                            AddSegment(builder, root + tip, root + tip + new Vector3(0.14f, 0f, side * 0.10f), 0.012f, new Vector4(i / 12f, side, 2f, 0.55f));
                        }
                    }
                }
            }

            // Further rock pairs share the fixed crack path.
            for (int i = 13; i < 26; i++)
            {
                AddRock(builder, i, -1);
                AddRock(builder, i, 1);
            }
            return builder.Build("MagmaFissureBody", VfxBurstMeshes.EffectBounds);
        }

        public static Mesh CreateParticles()
        {
            return VfxBurstMeshes.CreateTetrahedra("MagmaFissureParticles", MaxParticles, Seed);
        }

        private static float Wander(int i)
        {
            return Mathf.Sin(i * 2.2f) * 0.19f + Mathf.Sin(i * 0.79f) * 0.14f;
        }

        private static void AddSegment(VfxMeshBuilder builder, Vector3 from, Vector3 to, float radius, Vector4 data)
        {
            Vector3 direction = to - from;
            Quaternion turn = Quaternion.FromToRotation(Vector3.up, direction.normalized);
            Vector3 middle = (from + to) / 2f;
            VfxBurstMeshes.AddPrism(builder, radius, radius, direction.magnitude, 4, v => turn * v + middle, Vector2.zero, data);
        }

        private static void AddRock(VfxMeshBuilder builder, int i, int side)
        {
            int salt = i * 2 + (side == 1 ? 1 : 0);
            float jitter = Mathf.Sin(salt * 7.3f) * 0.11f;
            var scale = new Vector3(0.15f + salt % 4 * 0.045f, 0.12f + salt % 3 * 0.055f, 0.18f + salt % 5 * 0.035f);
            var center = new Vector3(-2.25f + i * 0.36f + jitter, 0.09f, Wander(i) + side * (0.22f + salt % 3 * 0.095f));

            Vector3 Place(Vector3 v)
            {
                v = Vector3.Scale(v, scale);
                v = RotateZ(v, jitter * 2.3f);
                v = RotateY(v, salt * 1.71f);
                v = RotateX(v, jitter * 1.5f);
                return v + center;
            }

            VfxBurstMeshes.AddFaces(builder, Dodecahedron, DodecahedronFaces, Place, new Vector2(center.x, center.z), new Vector4(i / 12f, side, 1f, -1f), i);
        }

        private static Vector3 RotateX(Vector3 v, float a)
        {
            float c = Mathf.Cos(a);
            float s = Mathf.Sin(a);
            return new Vector3(v.x, v.y * c - v.z * s, v.y * s + v.z * c);
        }

        private static Vector3 RotateY(Vector3 v, float a)
        {
            float c = Mathf.Cos(a);
            float s = Mathf.Sin(a);
            return new Vector3(v.x * c + v.z * s, v.y, -v.x * s + v.z * c);
        }

        private static Vector3 RotateZ(Vector3 v, float a)
        {
            float c = Mathf.Cos(a);
            float s = Mathf.Sin(a);
            return new Vector3(v.x * c - v.y * s, v.x * s + v.y * c, v.z);
        }

        private static readonly Vector3[] Dodecahedron = CreateDodecahedron();

        private static readonly int[] DodecahedronFaces =
        {
            3, 11, 7, 3, 7, 15, 3, 15, 13, 7, 19, 17, 7, 17, 6, 7, 6, 15, 17, 4, 8, 17, 8, 10, 17, 10, 6, 8, 0, 16, 8, 16, 2, 8, 2, 10,
            0, 12, 1, 0, 1, 18, 0, 18, 16, 6, 10, 2, 6, 2, 13, 6, 13, 15, 2, 16, 18, 2, 18, 3, 2, 3, 13, 18, 1, 9, 18, 9, 11, 18, 11, 3,
            4, 14, 12, 4, 12, 0, 4, 0, 8, 11, 9, 5, 11, 5, 19, 11, 19, 7, 19, 5, 14, 19, 14, 4, 19, 4, 17, 1, 12, 14, 1, 14, 5, 1, 5, 9
        };

        private static Vector3[] CreateDodecahedron()
        {
            float t = (1f + Mathf.Sqrt(5f)) / 2f;
            float r = 1f / t;
            Vector3[] vertices =
            {
                new Vector3(-1f, -1f, -1f), new Vector3(-1f, -1f, 1f), new Vector3(-1f, 1f, -1f), new Vector3(-1f, 1f, 1f),
                new Vector3(1f, -1f, -1f), new Vector3(1f, -1f, 1f), new Vector3(1f, 1f, -1f), new Vector3(1f, 1f, 1f),
                new Vector3(0f, -r, -t), new Vector3(0f, -r, t), new Vector3(0f, r, -t), new Vector3(0f, r, t),
                new Vector3(-r, -t, 0f), new Vector3(-r, t, 0f), new Vector3(r, -t, 0f), new Vector3(r, t, 0f),
                new Vector3(-t, 0f, -r), new Vector3(t, 0f, -r), new Vector3(-t, 0f, r), new Vector3(t, 0f, r)
            };

            for (int i = 0; i < vertices.Length; i++)
            {
                vertices[i] = vertices[i].normalized;
            }

            return vertices;
        }
    }
}
