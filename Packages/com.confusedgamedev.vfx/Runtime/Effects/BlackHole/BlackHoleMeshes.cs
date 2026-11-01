using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    public static class BlackHoleMeshes
    {
        public const int MaxParticles = 256;

        private const uint Seed = 719903;

        public static Mesh CreateRearDisk()
        {
            return CreateDisk("BlackHoleRearDisk");
        }

        public static Mesh CreateOuterLens()
        {
            var builder = new VfxMeshBuilder();
            builder.AddSphere(96, 48, new Vector3(3.05f, 0.58f, 3.05f));
            return builder.Build("BlackHoleOuterLens", EffectBounds);
        }

        public static Mesh CreateLens()
        {
            var builder = new VfxMeshBuilder();
            builder.AddSphere(64, 40, Vector3.one);
            return builder.Build("BlackHoleLens", EffectBounds);
        }

        public static Mesh CreateFrontDisk()
        {
            return CreateDisk("BlackHoleFrontDisk");
        }

        public static Mesh CreateInfall()
        {
            return VfxMeshes.CreateQuads("BlackHoleInfall", MaxParticles, EffectBounds, seeds: VfxMeshes.CreateSeeds(MaxParticles, Seed));
        }

        // Holds the disk, the lenses and the infall at size 12.
        private static readonly Bounds EffectBounds = new Bounds(new Vector3(0f, 18f, 0f), new Vector3(90f, 90f, 90f));

        // The source's TorusGeometry(1.65, 1, 12, 160). The vertex shader flattens it into the disk.
        private static Mesh CreateDisk(string name)
        {
            const int Radial = 12;
            const int Tubular = 160;
            var builder = new VfxMeshBuilder();
            for (int j = 0; j <= Radial; j++)
            {
                for (int i = 0; i <= Tubular; i++)
                {
                    float u = i / (float)Tubular * Mathf.PI * 2f;
                    float v = j / (float)Radial * Mathf.PI * 2f;
                    float ring = 1.65f + Mathf.Cos(v);
                    builder.AddVertex(new Vector3(ring * Mathf.Cos(u), ring * Mathf.Sin(u), Mathf.Sin(v)), Vector2.zero);
                }
            }

            for (int j = 1; j <= Radial; j++)
            {
                for (int i = 1; i <= Tubular; i++)
                {
                    int a = (Tubular + 1) * j + i - 1;
                    int b = (Tubular + 1) * (j - 1) + i - 1;
                    int c = (Tubular + 1) * (j - 1) + i;
                    int d = (Tubular + 1) * j + i;
                    builder.AddIndices(a, b, d, b, c, d);
                }
            }
            return builder.Build(name, EffectBounds);
        }
    }
}
