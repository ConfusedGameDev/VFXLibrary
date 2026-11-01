using System.Collections.Generic;
using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    public static class EnergyBurstMeshes
    {
        public const int MaxParticles = 768;
        public const int MaxClouds = 108;
        public const int MaxFragments = 36;

        private const uint Seed = 128618;

        private static readonly Bounds EffectBounds = new Bounds(Vector3.zero, new Vector3(16f, 16f, 16f));

        /// <summary>Sparks, clouds and fragments for a density, split the way the source splits its budget.</summary>
        public static Vector3Int LayerCounts(float density)
        {
            int desired = Mathf.Max(1, Mathf.RoundToInt(MaxParticles * density));
            int fragments = Mathf.Min(MaxFragments, Mathf.RoundToInt(desired * 0.06f));
            int clouds = Mathf.Min(MaxClouds, Mathf.RoundToInt(desired * 0.14f));
            return new Vector3Int(desired - fragments - clouds, clouds, fragments);
        }

        public static Mesh CreateArcs()
        {
            var positions = new List<Vector3>();
            var uvs = new List<Vector2>();
            var units = new List<Vector2>();
            var indices = new List<int>();

            for (int branch = 71; branch >= 0; branch--)
            {
                int role = (branch % 36) / 12;
                int unit = branch % 12 + (branch >= 36 ? 12 : 0);
                int steps = role == 0 ? 64 : 16;
                for (int step = 0; step < steps; step++)
                {
                    int first = positions.Count;
                    for (int corner = 0; corner < 4; corner++)
                    {
                        positions.Add(new Vector3((float)step / steps, (step + 1f) / steps, branch));
                        uvs.Add(new Vector2(corner & 1, corner >> 1));
                        units.Add(new Vector2(unit, role));
                    }
                    indices.Add(first);
                    indices.Add(first + 1);
                    indices.Add(first + 2);
                    indices.Add(first + 2);
                    indices.Add(first + 1);
                    indices.Add(first + 3);
                }
            }

            var mesh = new Mesh { name = "EnergyBurstArcs", indexFormat = UnityEngine.Rendering.IndexFormat.UInt32 };
            mesh.SetVertices(positions);
            mesh.SetUVs(0, uvs);
            mesh.SetUVs(1, units);
            mesh.SetTriangles(indices, 0);
            mesh.bounds = EffectBounds;
            return mesh;
        }

        public static Mesh CreateSparks()
        {
            return VfxMeshes.CreateQuads("EnergyBurstSparks", MaxParticles, EffectBounds, seeds: VfxMeshes.CreateSeeds(MaxParticles, Seed));
        }

        public static Mesh CreateClouds()
        {
            return VfxMeshes.CreateQuads("EnergyBurstClouds", MaxClouds, EffectBounds, seeds: VfxMeshes.CreateSeeds(MaxClouds, Seed, 1));
        }

        public static Mesh CreateFragments()
        {
            return VfxMeshes.CreateQuads("EnergyBurstFragments", MaxFragments, EffectBounds, segments: 4, seeds: VfxMeshes.CreateSeeds(MaxFragments, Seed, 2));
        }

        public static Mesh CreateFlash()
        {
            return VfxMeshes.CreateQuads("EnergyBurstFlash", 1, EffectBounds, 2f);
        }

        public static Mesh CreateWave()
        {
            return VfxMeshes.CreateQuads("EnergyBurstWave", 1, EffectBounds, 7f);
        }
    }
}
