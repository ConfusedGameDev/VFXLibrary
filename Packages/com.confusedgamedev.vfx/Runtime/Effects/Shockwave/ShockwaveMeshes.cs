using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    public static class ShockwaveMeshes
    {
        public const int MaxParticles = 512;

        private const uint Seed = 137805;

        private static readonly int[] Maxima = { 512, 72, 18, 28 };
        private static readonly float[] Weights = { 0.86f, 0.14f, 0.045f, 0.055f };

        /// <summary>Instances per layer for a density, split the way the source splits its budget.</summary>
        public static Vector4 LayerCounts(float density)
        {
            return VfxBurstMeshes.LayerCounts(MaxParticles, 7, density, Maxima, Weights);
        }

        public static Mesh CreateSparks()
        {
            return VfxMeshes.CreateQuads("ShockwaveSparks", MaxParticles, VfxBurstMeshes.EffectBounds, seeds: VfxMeshes.CreateSeeds(MaxParticles, Seed, 0));
        }

        public static Mesh CreateClouds()
        {
            return VfxMeshes.CreateQuads("ShockwaveClouds", 72, VfxBurstMeshes.EffectBounds, seeds: VfxMeshes.CreateSeeds(72, Seed, 1));
        }

        public static Mesh CreateRoll()
        {
            return VfxMeshes.CreateQuads("ShockwaveRoll", 7, VfxBurstMeshes.EffectBounds);
        }

        public static Mesh CreateFans()
        {
            var shape = new VfxMeshBuilder();
            shape.AddPatch(12, 1, (u, v) => new Vector3(u - 0.5f, v - 0.5f, 0f));
            return VfxMeshBuilder.Instance("ShockwaveFans", shape, VfxMeshes.CreateSeeds(18, Seed, 2), VfxBurstMeshes.EffectBounds);
        }

        public static Mesh CreateChips()
        {
            var shape = new VfxMeshBuilder();
            Vector3[] corners = { new Vector3(1f, 1f, 1f), new Vector3(-1f, -1f, 1f), new Vector3(-1f, 1f, -1f), new Vector3(1f, -1f, -1f) };
            int[] faces = { 2, 1, 0, 0, 3, 2, 1, 3, 0, 2, 3, 1 };
            for (int i = 0; i < faces.Length; i += 3)
            {
                shape.AddFlatTriangle(corners[faces[i]].normalized * 0.075f, corners[faces[i + 1]].normalized * 0.075f, corners[faces[i + 2]].normalized * 0.075f, Vector2.zero, Vector2.zero, Vector2.zero);
            }
            return VfxMeshBuilder.Instance("ShockwaveChips", shape, VfxMeshes.CreateSeeds(28, Seed, 3), VfxBurstMeshes.EffectBounds);
        }

        public static Mesh CreateWave()
        {
            return VfxMeshes.CreateQuads("ShockwaveWave", 1, VfxBurstMeshes.EffectBounds, 7f);
        }
    }
}
