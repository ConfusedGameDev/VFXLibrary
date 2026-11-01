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
            Vector4[] seeds = CreateSeeds(MaxParticles);
            var extras = new List<Vector4>(MaxParticles * 4);
            for (int i = 0; i < MaxParticles; i++)
            {
                for (int corner = 0; corner < 4; corner++)
                {
                    extras.Add(seeds[i]);
                }
            }

            Mesh mesh = CreateQuads("FireballParticles", MaxParticles, 1f);
            mesh.SetUVs(1, extras);
            return mesh;
        }

        public static Mesh CreateImpact()
        {
            return CreateQuads("FireballImpact", ImpactPuffs, 1f);
        }

        public static Mesh CreateGlow()
        {
            return CreateQuads("FireballGlow", 1, 1.8f);
        }

        /// <summary>Same generator as the source, so particles land where they do on the site.</summary>
        public static Vector4[] CreateSeeds(int count)
        {
            var seeds = new Vector4[count];
            uint state = ParticleSeed;
            for (int i = 0; i < count; i++)
            {
                for (int component = 0; component < 4; component++)
                {
                    state = unchecked(state * 1664525u + 1013904223u);
                    seeds[i][component] = (float)(state / 4294967296.0);
                }
            }
            return seeds;
        }

        // UV2.x carries the quad's index.
        private static Mesh CreateQuads(string name, int count, float width)
        {
            var positions = new List<Vector3>(count * 4);
            var uvs = new List<Vector2>(count * 4);
            var ids = new List<Vector2>(count * 4);
            var indices = new List<int>(count * 6);

            for (int i = 0; i < count; i++)
            {
                int first = positions.Count;
                for (int v = 0; v <= 1; v++)
                {
                    for (int u = 0; u <= 1; u++)
                    {
                        positions.Add(new Vector3((u - 0.5f) * width, (v - 0.5f) * width, 0f));
                        uvs.Add(new Vector2(u, v));
                        ids.Add(new Vector2(i, 0f));
                    }
                }

                indices.Add(first);
                indices.Add(first + 2);
                indices.Add(first + 1);
                indices.Add(first + 2);
                indices.Add(first + 3);
                indices.Add(first + 1);
            }

            var mesh = new Mesh { name = name };
            mesh.SetVertices(positions);
            mesh.SetUVs(0, uvs);
            mesh.SetUVs(2, ids);
            mesh.SetTriangles(indices, 0);
            mesh.bounds = EffectBounds;
            return mesh;
        }
    }
}
