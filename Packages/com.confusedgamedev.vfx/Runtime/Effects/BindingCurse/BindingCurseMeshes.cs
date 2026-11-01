using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    public static class BindingCurseMeshes
    {
        public const int MaxParticles = 512;

        private const uint Seed = 352154;

        public static Mesh CreateSigil()
        {
            return VfxGroundMeshes.CreateFlat("BindingCurseSigil", 3.5f);
        }

        /// <summary>Six tubes, reshaped from their UVs in the vertex shader. UV1 holds phase and quantity unit.</summary>
        public static Mesh CreateBody()
        {
            var builder = new VfxMeshBuilder();
            for (int i = 0; i < 6; i++)
            {
                float a = i * Mathf.PI * 2f / (i < 3 ? 3f : 6f);
                VfxGroundMeshes.AddTube(builder, u =>
                {
                    float b = a + u * 2.7f;
                    float r = 0.4f + Mathf.Sin(u * Mathf.PI) * 0.8f;
                    return new Vector3(Mathf.Cos(b) * r, 0.12f + Mathf.Sin(u * Mathf.PI) * 1.65f, Mathf.Sin(b) * r);
                }, u => 0.045f + 0.035f * Mathf.Sin(u * Mathf.PI), 36, 6, new Vector4(i * 2.1f, i, 0f, 0f), 1f);
            }

            builder.ComputeNormals();
            return builder.Build("BindingCurseBody", VfxGroundMeshes.EffectBounds);
        }

        public static Mesh CreateParticles()
        {
            return VfxGroundMeshes.CreateParticles("BindingCurseParticles", MaxParticles, Seed);
        }
    }
}
