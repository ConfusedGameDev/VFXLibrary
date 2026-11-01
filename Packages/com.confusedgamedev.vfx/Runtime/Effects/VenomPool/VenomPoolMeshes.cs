using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    public static class VenomPoolMeshes
    {
        public const int MaxParticles = 512;
        public const int MaxMist = 32;

        private const uint Seed = 422203;
        private const int DomeSides = 16;
        private const int DomeRings = 10;

        public static Mesh CreateSigil()
        {
            return VfxGroundMeshes.CreateFlat("VenomPoolSigil", 3.5f);
        }

        /// <summary>Fourteen open hemispheres. UV1 holds phase and quantity unit.</summary>
        public static Mesh CreateBody()
        {
            var builder = new VfxMeshBuilder();
            for (int i = 0; i < 14; i++)
            {
                float a = i * 2.4f;
                float r = i == 0 ? 0f : 0.55f + i % 2 * 0.35f;
                var center = new Vector3(Mathf.Cos(a) * r, 0.04f, Mathf.Sin(a) * r);
                AddDome(builder, 0.24f + i % 3 * 0.07f, center, new Vector4(i * 1.4f, i, 0f, 0f));
            }

            return builder.Build("VenomPoolBody", VfxGroundMeshes.EffectBounds);
        }

        public static Mesh CreateParticles()
        {
            return VfxGroundMeshes.CreateParticles("VenomPoolParticles", MaxParticles, Seed);
        }

        public static Mesh CreateMist()
        {
            return VfxGroundMeshes.CreateParticles("VenomPoolMist", MaxMist, Seed, 1);
        }

        private static void AddDome(VfxMeshBuilder builder, float radius, Vector3 center, Vector4 extra)
        {
            int first = builder.VertexCount;
            for (int y = 0; y <= DomeRings; y++)
            {
                float v = (float)y / DomeRings;
                for (int x = 0; x <= DomeSides; x++)
                {
                    float u = (float)x / DomeSides;
                    float azimuth = u * Mathf.PI * 2f;
                    float polar = v * Mathf.PI * 0.5f;
                    var unit = new Vector3(-Mathf.Cos(azimuth) * Mathf.Sin(polar), Mathf.Cos(polar), Mathf.Sin(azimuth) * Mathf.Sin(polar));
                    builder.AddLitVertex(unit * radius + center, unit, new Vector2(u, 1f - v), extra, 1f);
                }
            }

            for (int y = 0; y < DomeRings; y++)
            {
                for (int x = 0; x < DomeSides; x++)
                {
                    int a = first + y * (DomeSides + 1) + x + 1;
                    int b = a - 1;
                    int c = b + DomeSides + 1;
                    int d = c + 1;
                    if (y > 0)
                    {
                        builder.AddIndices(a, b, d);
                    }

                    builder.AddIndices(b, c, d);
                }
            }
        }
    }
}
