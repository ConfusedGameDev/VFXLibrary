using System.Collections.Generic;
using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>
    /// Builds the fireball's meshes. Shaders do all the shaping, so these only carry the UVs and seeds
    /// they read. Bounds are set by hand because vertices move far from where they are stored.
    /// </summary>
    public static class FireballMeshes
    {
        public const int MaxParticles = 768;
        public const int ImpactPuffs = 12;

        private const int CoreRings = 48;
        private const int CoreSides = 20;
        private const uint ParticleSeed = 9187;

        // Holds the longest reach at size 2, including the ending's stretch and impact puffs.
        private static readonly Bounds EffectBounds = new Bounds(new Vector3(0f, 0f, -1f), new Vector3(9f, 9f, 13f));

        public static Mesh CreateCore()
        {
            var positions = new List<Vector3>();
            var uvs = new List<Vector2>();
            var indices = new List<int>();

            for (int ring = 0; ring <= CoreRings; ring++)
            {
                for (int side = 0; side <= CoreSides; side++)
                {
                    positions.Add(Vector3.zero);
                    uvs.Add(new Vector2((float)ring / CoreRings, (float)side / CoreSides));
                }
            }

            for (int ring = 0; ring < CoreRings; ring++)
            {
                for (int side = 0; side < CoreSides; side++)
                {
                    int corner = ring * (CoreSides + 1) + side;
                    indices.Add(corner);
                    indices.Add(corner + 1);
                    indices.Add(corner + CoreSides + 1);
                    indices.Add(corner + 1);
                    indices.Add(corner + CoreSides + 2);
                    indices.Add(corner + CoreSides + 1);
                }
            }

            var mesh = new Mesh { name = "FireballCore" };
            mesh.SetVertices(positions);
            mesh.SetUVs(0, uvs);
            mesh.SetTriangles(indices, 0);
            mesh.bounds = EffectBounds;
            return mesh;
        }

        /// <summary>One quad per particle. The shader collapses quads past the density-driven count.</summary>
        public static Mesh CreateParticles()
        {
            return VfxMeshes.CreateQuads("FireballParticles", MaxParticles, EffectBounds, seeds: CreateSeeds(MaxParticles));
        }

        public static Mesh CreateImpact()
        {
            return VfxMeshes.CreateQuads("FireballImpact", ImpactPuffs, EffectBounds);
        }

        public static Mesh CreateGlow()
        {
            return VfxMeshes.CreateQuads("FireballGlow", 1, EffectBounds, 1.8f);
        }

        public static Vector4[] CreateSeeds(int count)
        {
            return VfxMeshes.CreateSeeds(count, ParticleSeed);
        }
    }
}
