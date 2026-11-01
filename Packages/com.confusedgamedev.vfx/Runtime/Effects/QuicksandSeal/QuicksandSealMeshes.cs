using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    public static class QuicksandSealMeshes
    {
        public const int MaxParticles = 512;

        private const uint Seed = 392182;

        public static Mesh CreateSigil()
        {
            return VfxGroundMeshes.CreateFlat("QuicksandSealSigil", 3.5f);
        }

        /// <summary>Flat patches, shaped from their UVs in the vertex shader. UV1 holds phase and bank.</summary>
        public static Mesh CreateBody()
        {
            var builder = new VfxMeshBuilder();
            for (int k = 0; k < 6; k++)
            {
                AddPatch(builder, k, k % 3);
            }

            for (int k = 3; k < 6; k++)
            {
                AddPatch(builder, k, k);
                AddPatch(builder, k + 6, k);
            }

            builder.ComputeNormals();
            return builder.Build("QuicksandSealBody", VfxGroundMeshes.EffectBounds);
        }

        public static Mesh CreateParticles()
        {
            return VfxGroundMeshes.CreateParticles("QuicksandSealParticles", MaxParticles, Seed);
        }

        private static void AddPatch(VfxMeshBuilder builder, int phase, int bank)
        {
            builder.AddSurface(24, 10, (u, v) => new Vector3(u, v, phase), new Vector4(phase, bank, 0f, 0f), 1f);
        }
    }
}
