using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    public static class FrostLanceRainMeshes
    {
        public const int MaxParticles = 512;

        private const uint Seed = 413415;

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
            Vector3[] facet = VfxBurstMeshes.OctahedronVertices;
            int[] faces = VfxBurstMeshes.OctahedronFaces;
            for (int i = 0; i < 18; i++)
            {
                float a = i * 2.39996f;
                float r = i == 0 ? 0f : 0.55f + 0.8f * (i % 3) / 2f;
                var c = new Vector3(Mathf.Cos(a) * r, 0f, Mathf.Sin(a) * r);
                var uv = new Vector2(c.x, c.z);
                VfxBurstMeshes.AddFaces(builder, facet, faces, v => Vector3.Scale(v, new Vector3(0.13f, 0.64f, 0.13f)) + new Vector3(0f, 0.64f, 0f) + c, uv, new Vector4(i / 9f, a, 0f, 0.27f));
                for (int j = 0; j < 3; j++)
                {
                    float tilt = (j - 1) * 0.8f;
                    float cos = Mathf.Cos(tilt);
                    float sin = Mathf.Sin(tilt);
                    VfxBurstMeshes.AddFaces(builder, facet, faces, v =>
                    {
                        Vector3 s = Vector3.Scale(v, new Vector3(0.075f, 0.15f, 0.075f));
                        return new Vector3(s.x * cos - s.y * sin, s.x * sin + s.y * cos, s.z) + c;
                    }, uv, new Vector4(i / 9f, a + j * Tau / 3f, 1f, 0.67f));
                }

                Vector3 patch = c + new Vector3(0f, 0.025f, 0f);
                VfxBurstMeshes.AddPrism(builder, 0.25f, 0.31f, 0.045f, 6, v => v + patch, uv, new Vector4(i / 9f, a, 2f, 0.12f));
            }
            return builder.Build("FrostLanceRainBody", VfxBurstMeshes.EffectBounds);
        }

        public static Mesh CreateParticles()
        {
            return VfxBurstMeshes.CreateTetrahedra("FrostLanceRainParticles", MaxParticles, Seed);
        }
    }
}
