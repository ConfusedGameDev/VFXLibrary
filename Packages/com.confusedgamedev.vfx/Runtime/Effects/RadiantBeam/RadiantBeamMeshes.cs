using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    public static class RadiantBeamMeshes
    {
        public const int MaxParticles = 512;

        private const uint Seed = 342147;

        public static Mesh CreateBody()
        {
            var builder = new VfxMeshBuilder();
            AddShaft(builder, 0.042f, 0);
            AddShaft(builder, 0.11f, 2);

            foreach (float end in new[] { -1f, 1f })
            {
                float x = end * 2.4f;
                AddRing(builder, x);

                float reach = end < 0f ? 0.58f : 0.85f;
                for (int k = 0; k < 7; k++)
                {
                    float a = k * Mathf.PI * 2f / 7f;
                    float cos = Mathf.Cos(a);
                    float sin = Mathf.Sin(a);
                    builder.AddSurface(18, 6, (u, v) =>
                    {
                        float radius = 0.08f + u * reach;
                        float width = Mathf.Sin(u * Mathf.PI) * 0.12f * Mathf.Sin(v * Mathf.PI) * Mathf.Cos(v * Mathf.PI);
                        return new Vector3(x + Mathf.Sin(u * Mathf.PI) * 0.22f, cos * radius - sin * width, sin * radius + cos * width);
                    }, part: 1);
                }
            }

            return builder.Build("RadiantBeamBody", VfxMeshes.BeamBounds);
        }

        public static Mesh CreateParticles()
        {
            return VfxMeshes.CreateQuads("RadiantBeamParticles", MaxParticles, VfxMeshes.BeamBounds, seeds: VfxMeshes.CreateSeeds(MaxParticles, Seed));
        }

        private static void AddShaft(VfxMeshBuilder builder, float radius, int part)
        {
            builder.AddSurface(32, 10, (u, v) =>
            {
                float a = v * Mathf.PI * 2f;
                return new Vector3(u * 4.8f - 2.4f, Mathf.Cos(a) * radius, Mathf.Sin(a) * radius);
            }, part: part);
        }

        // The source's tube() around the beam: the frame comes from the tangent, which never points along Y here except at the ring's sides.
        private static void AddRing(VfxMeshBuilder builder, float x)
        {
            const float RingRadius = 0.42f;
            const float TubeRadius = 0.012f;

            Vector3 Center(float u)
            {
                float a = u * Mathf.PI * 2f;
                return new Vector3(x, Mathf.Cos(a) * RingRadius, Mathf.Sin(a) * RingRadius);
            }

            builder.AddSurface(48, 4, (u, v) =>
            {
                Vector3 tangent = (Center(Mathf.Min(1f, u + 0.001f)) - Center(Mathf.Max(0f, u - 0.001f))).normalized;
                Vector3 side = Vector3.Cross(tangent, Mathf.Abs(tangent.y) > 0.9f ? Vector3.right : Vector3.up).normalized;
                Vector3 normal = Vector3.Cross(tangent, side);
                float a = v * Mathf.PI * 2f;
                return Center(u) + side * (Mathf.Cos(a) * TubeRadius) + normal * (Mathf.Sin(a) * TubeRadius);
            }, part: 1);
        }
    }
}
