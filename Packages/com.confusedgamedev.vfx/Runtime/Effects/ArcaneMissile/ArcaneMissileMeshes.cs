using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    public static class ArcaneMissileMeshes
    {
        public const int MaxParticles = 768;
        public const int MaxMissiles = 6;

        private const uint Seed = 36748;

        private static readonly Bounds EffectBounds = VfxMeshes.ProjectileBounds;

        public static Mesh CreateParticles()
        {
            return VfxMeshes.CreateQuads("ArcaneMissileParticles", MaxParticles, EffectBounds, seeds: VfxMeshes.CreateSeeds(MaxParticles, Seed));
        }

        /// <summary>Six octahedra, always allocated. Those past the quantity are discarded.</summary>
        public static Mesh CreateGems()
        {
            var builder = new VfxMeshBuilder();
            for (int i = 0; i < MaxMissiles; i++)
            {
                builder.AddOctahedron(0.13f, part: i);
            }
            builder.ComputeNormals();
            return builder.Build("ArcaneMissileGems", EffectBounds);
        }

        public static Mesh CreateTrails()
        {
            var builder = new VfxMeshBuilder();
            for (int arm = 0; arm < MaxMissiles; arm++)
            {
                int unit = arm;
                builder.AddStrip(64, (h, side) => new Vector3(h, unit, side));
            }
            return builder.Build("ArcaneMissileTrails", EffectBounds);
        }

        /// <summary>Seven groups of a small rune and a crystal, tumbling apart.</summary>
        public static Mesh CreateImpact()
        {
            var builder = new VfxMeshBuilder();
            for (int i = 0; i < 7; i++)
            {
                float a = i * 2.39996f;
                float r = 0.3f + i % 3 * 0.13f;
                var center = new Vector3(i % 3 * 0.33f, Mathf.Cos(a) * r, Mathf.Sin(a) * r);
                Quaternion turn = Quaternion.AngleAxis(i * 0.63f * Mathf.Rad2Deg, Vector3.right)
                    * Quaternion.AngleAxis(i * 0.77f * Mathf.Rad2Deg, Vector3.up)
                    * Quaternion.AngleAxis(i * 0.4f * Mathf.Rad2Deg, Vector3.forward);

                AddLine(builder, new Vector2(-0.15f, -0.2f), new Vector2(-0.15f, 0.2f), turn, center, i);
                AddLine(builder, new Vector2(-0.15f, 0.12f), new Vector2(0.13f, -0.02f), turn, center, i);
                AddLine(builder, new Vector2(-0.15f, -0.08f), new Vector2(0.1f, -0.2f), turn, center, i);
                if (i % 2 == 0)
                {
                    AddLine(builder, new Vector2(0.1f, -0.2f), new Vector2(0.1f, 0.12f), turn, center, i);
                }

                builder.AddCrystal(center, i, 0.11f, 0.055f);
            }
            return builder.Build("ArcaneMissileImpact", EffectBounds);
        }

        public static Mesh CreateGlow()
        {
            return VfxMeshes.CreateQuads("ArcaneMissileGlow", 1, EffectBounds, 1.8f);
        }

        private static void AddLine(VfxMeshBuilder builder, Vector2 from, Vector2 to, Quaternion turn, Vector3 center, int part)
        {
            builder.AddPatch(1, 1, (u, v) =>
            {
                float y = from.x + (to.x - from.x) * u + (v - 0.5f) * 0.025f;
                float z = from.y + (to.y - from.y) * u;
                return turn * new Vector3(0f, y, z) + center;
            }, center, part);
        }
    }
}
