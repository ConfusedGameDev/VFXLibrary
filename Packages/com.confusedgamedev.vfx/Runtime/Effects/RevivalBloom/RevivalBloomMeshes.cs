using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    public static class RevivalBloomMeshes
    {
        public const int MaxParticles = 512;

        private const uint Seed = 404228;

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
            const float Tau = Mathf.PI * 2f;
            for (int ring = 0; ring < 2; ring++)
            {
                for (int i = 0; i < 14; i++)
                {
                    float a = (i + ring * 0.5f) * Tau / 7f;
                    AddPetal(builder, new Vector4(i / 7f, a, ring, 0.21f + ring * 0.18f), i * 2 + ring);
                }
            }

            for (int i = 0; i < 5; i++)
            {
                float a = i * Tau / 5f;
                var center = new Vector3(Mathf.Cos(a) * 0.28f, 0.10f, Mathf.Sin(a) * 0.28f);
                VfxBurstMeshes.AddFaces(builder, VfxBurstMeshes.OctahedronVertices, VfxBurstMeshes.OctahedronFaces, v => Vector3.Scale(v, new Vector3(0.06f, 0.14f, 0.06f)) + center, Vector2.zero, new Vector4(i / 5f, a, 2f, 0.75f));
            }
            return builder.Build("RevivalBloomBody", VfxBurstMeshes.EffectBounds);
        }

        public static Mesh CreateParticles()
        {
            return VfxBurstMeshes.CreateTetrahedra("RevivalBloomParticles", MaxParticles, Seed);
        }

        // A thin slab that the vertex shader bends open. Each ring of four corners sits at height h.
        private static void AddPetal(VfxMeshBuilder builder, Vector4 data, float unit)
        {
            int[,] sides = { { 0, 1 }, { 1, 3 }, { 3, 2 }, { 2, 0 } };

            Vector3 Corner(int step, int corner)
            {
                float h = step / 9f;
                float width = 0.46f * Mathf.Pow(Mathf.Abs(Mathf.Sin(h * Mathf.PI)), 0.75f) + 0.012f;
                return new Vector3((corner & 1) == 0 ? -width : width, h, (corner & 2) == 0 ? -0.045f : 0.045f);
            }

            for (int i = 0; i < 9; i++)
            {
                for (int side = 0; side < 4; side++)
                {
                    Vector3 a = Corner(i, sides[side, 0]);
                    Vector3 b = Corner(i + 1, sides[side, 0]);
                    Vector3 c = Corner(i + 1, sides[side, 1]);
                    Vector3 d = Corner(i, sides[side, 1]);
                    builder.AddFlatTriangle(a, b, c, Vector2.zero, Vector2.zero, Vector2.zero, data, unit);
                    builder.AddFlatTriangle(a, c, d, Vector2.zero, Vector2.zero, Vector2.zero, data, unit);
                }
            }
        }
    }
}
