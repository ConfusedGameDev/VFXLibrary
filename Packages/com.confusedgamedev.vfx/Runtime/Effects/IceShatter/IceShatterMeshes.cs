using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    public static class IceShatterMeshes
    {
        public const int MaxParticles = 768;

        private const uint Seed = 146992;

        private static readonly int[] Maxima = { 768, 108, 62 };
        private static readonly float[] Weights = { 0.86f, 0.14f, 0.08f };

        /// <summary>Instances per layer for a density, split the way the source splits its budget.</summary>
        public static Vector4 LayerCounts(float density)
        {
            return VfxBurstMeshes.LayerCounts(MaxParticles, 0, density, Maxima, Weights);
        }

        public static Mesh CreateSparks()
        {
            return VfxMeshes.CreateQuads("IceShatterSparks", MaxParticles, VfxBurstMeshes.EffectBounds, seeds: VfxMeshes.CreateSeeds(MaxParticles, Seed, 0));
        }

        public static Mesh CreateClouds()
        {
            return VfxMeshes.CreateQuads("IceShatterClouds", 108, VfxBurstMeshes.EffectBounds, seeds: VfxMeshes.CreateSeeds(108, Seed, 1));
        }

        public static Mesh CreateCrystals()
        {
            var builder = new VfxMeshBuilder();
            int[] faces = { 0, 2, 1, 0, 3, 2, 0, 4, 3, 0, 1, 4, 5, 1, 2, 5, 2, 3, 5, 3, 4, 5, 4, 1 };
            for (int i = 0; i < 18; i++)
            {
                // The original nine, then nine more between them on the same radius.
                float seed = i < 9 ? i / 9f : (i - 9 + 0.5f) / 9f;
                float a = seed * Mathf.PI * 2f;
                float r = i == 0 ? 0f : 0.25f + i % 3 * 0.12f;
                float h = 1.3f + i % 4 * 0.35f;
                var data = new Vector4(Mathf.Cos(a) * r, 0f, Mathf.Sin(a) * r, seed);
                Vector3[] points =
                {
                    new Vector3(0f, -0.12f, 0f), new Vector3(0.19f, 0.4f, 0f), new Vector3(0f, 0.4f, 0.19f),
                    new Vector3(-0.19f, 0.4f, 0f), new Vector3(0f, 0.4f, -0.19f), new Vector3(Mathf.Cos(a) * 0.35f, h, Mathf.Sin(a) * 0.35f)
                };
                for (int face = 0; face < faces.Length; face += 3)
                {
                    builder.AddFlatTriangle(points[faces[face]], points[faces[face + 1]], points[faces[face + 2]], Vector2.zero, Vector2.zero, Vector2.zero, data, i);
                }
            }
            return builder.Build("IceShatterCrystals", VfxBurstMeshes.EffectBounds);
        }

        public static Mesh CreateShards()
        {
            var shape = new VfxMeshBuilder();
            shape.AddOctahedron(0.12f);
            return VfxMeshBuilder.Instance("IceShatterShards", shape, VfxMeshes.CreateSeeds(62, Seed, 2), VfxBurstMeshes.EffectBounds);
        }

        public static Mesh CreateWave()
        {
            return VfxMeshes.CreateQuads("IceShatterWave", 1, VfxBurstMeshes.EffectBounds, 7f);
        }
    }
}
