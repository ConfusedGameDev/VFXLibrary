using System.Collections.Generic;
using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    public static class MagicBarrierMeshes
    {
        public const int MaxParticles = 768;

        private const uint Seed = 110244;
        private const int DomeSides = 40;
        private const int DomeRings = 20;
        private const float DomeRadius = 1.85f;

        private static readonly Bounds EffectBounds = new Bounds(new Vector3(0f, 1.5f, 0f), new Vector3(10f, 7f, 10f));

        public static Mesh CreateAura()
        {
            return VfxMeshes.CreateGrid("MagicBarrierAura", 4.8f, 24, EffectBounds);
        }

        public static Mesh CreateSigil()
        {
            return VfxMeshes.CreateGrid("MagicBarrierSigil", 4.5f, 24, EffectBounds);
        }

        /// <summary>The shield's upper hemisphere, in the source's axes and UV layout.</summary>
        public static Mesh CreateShield()
        {
            var positions = new List<Vector3>();
            var uvs = new List<Vector2>();
            var indices = new List<int>();

            for (int ring = 0; ring <= DomeRings; ring++)
            {
                float v = (float)ring / DomeRings;
                float theta = v * Mathf.PI * 0.5f;
                for (int side = 0; side <= DomeSides; side++)
                {
                    float u = (float)side / DomeSides;
                    float phi = u * Mathf.PI * 2f;
                    positions.Add(DomeRadius * new Vector3(
                        -Mathf.Cos(phi) * Mathf.Sin(theta),
                        Mathf.Cos(theta),
                        Mathf.Sin(phi) * Mathf.Sin(theta)));
                    uvs.Add(new Vector2(u, 1f - v));
                }
            }

            for (int ring = 0; ring < DomeRings; ring++)
            {
                for (int side = 0; side < DomeSides; side++)
                {
                    int corner = ring * (DomeSides + 1) + side;
                    int below = corner + DomeSides + 1;
                    indices.Add(corner);
                    indices.Add(below);
                    indices.Add(corner + 1);
                    indices.Add(below);
                    indices.Add(below + 1);
                    indices.Add(corner + 1);
                }
            }

            var mesh = new Mesh { name = "MagicBarrierShield" };
            mesh.SetVertices(positions);
            mesh.SetUVs(0, uvs);
            mesh.SetTriangles(indices, 0);
            mesh.bounds = EffectBounds;
            return mesh;
        }

        public static Mesh CreateParticles()
        {
            return VfxMeshes.CreateQuads("MagicBarrierParticles", MaxParticles, EffectBounds, seeds: VfxMeshes.CreateSeeds(MaxParticles, Seed));
        }
    }
}
