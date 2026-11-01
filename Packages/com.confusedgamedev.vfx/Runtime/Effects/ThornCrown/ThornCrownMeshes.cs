using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    public static class ThornCrownMeshes
    {
        public const int MaxParticles = 512;

        private const uint Seed = 362161;

        public static Mesh CreateSigil()
        {
            return VfxGroundMeshes.CreateFlat("ThornCrownSigil", 3.5f);
        }

        /// <summary>Eight vines with three leaves and thorns each, then the blossom. UV1 holds phase and quantity unit.</summary>
        public static Mesh CreateBody()
        {
            var builder = new VfxMeshBuilder();
            for (int k = 0; k < 8; k++)
            {
                float a = k * Mathf.PI * 2f / (k < 4 ? 4f : 8f);
                var extra = new Vector4(k, k, 0f, 0f);
                VfxGroundMeshes.AddTube(builder, u =>
                {
                    float r = 0.8f + Mathf.Sin(u * 3.8f) * 0.3f;
                    float b = a + u * 1.7f;
                    return new Vector3(Mathf.Cos(b) * r, u * 1.65f, Mathf.Sin(b) * r);
                }, u => 0.065f * (1f - u * 0.6f), 30, 6, extra, 1f);

                for (int j = 0; j < 3; j++)
                {
                    float h = 0.35f + j * 0.43f;
                    float b = a + h;
                    builder.AddSurface(10, 4, (u, v) =>
                    {
                        float w = Mathf.Sin(u * Mathf.PI) * 0.18f * (v * 2f - 1f);
                        float r = 1.05f + u * 0.55f;
                        return new Vector3(
                            Mathf.Cos(b) * r - Mathf.Sin(b) * w,
                            h + Mathf.Sin(u * 2.5f) * 0.25f + Mathf.Abs(w) * 0.3f,
                            Mathf.Sin(b) * r + Mathf.Cos(b) * w);
                    }, extra, 2f);
                    VfxGroundMeshes.AddGem(builder, new Vector3(Mathf.Cos(b) * 0.94f, h, Mathf.Sin(b) * 0.94f), new Vector3(0.08f, 0.2f, 0.08f), k, extra, 2f);
                }
            }

            for (int k = 0; k < 7; k++)
            {
                float a = k * Mathf.PI * 2f / 7f;
                builder.AddSurface(10, 4, (u, v) =>
                {
                    float r = 0.12f + u * 0.55f;
                    float w = Mathf.Sin(u * Mathf.PI) * 0.18f * (v * 2f - 1f);
                    return new Vector3(Mathf.Cos(a) * r - Mathf.Sin(a) * w, 0.65f + u * 0.3f + v * (1f - v) * 0.15f, Mathf.Sin(a) * r + Mathf.Cos(a) * w);
                }, new Vector4(k, -1f, 0f, 0f), 3f);
            }

            builder.ComputeNormals();
            return builder.Build("ThornCrownBody", VfxGroundMeshes.EffectBounds);
        }

        public static Mesh CreateParticles()
        {
            return VfxGroundMeshes.CreateParticles("ThornCrownParticles", MaxParticles, Seed);
        }
    }
}
