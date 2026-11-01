using System;
using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Mesh helpers shared by the ground effects, built in the source's axes.</summary>
    public static class VfxGroundMeshes
    {
        // Holds a ground effect at size 2, including what its ending throws outward.
        public static readonly Bounds EffectBounds = new Bounds(new Vector3(0f, 1.5f, 0f), new Vector3(12f, 7f, 12f));

        public static Mesh CreateFlat(string name, float width)
        {
            return VfxMeshes.CreateGrid(name, width, 24, EffectBounds);
        }

        public static Mesh CreateParticles(string name, int count, uint seed, int layerIndex = 0)
        {
            return VfxMeshes.CreateQuads(name, count, EffectBounds, seeds: VfxMeshes.CreateSeeds(count, seed, layerIndex));
        }

        /// <summary>The source's tube(): a ring of sides swept along path, with the radius varying along it.</summary>
        public static void AddTube(VfxMeshBuilder builder, Func<float, Vector3> path, Func<float, float> radius, int steps, int sides, Vector4 extra = default, float part = 0f)
        {
            builder.AddSurface(steps, sides, (u, v) =>
            {
                Vector3 tangent = (path(Mathf.Min(1f, u + 0.001f)) - path(Mathf.Max(0f, u - 0.001f))).normalized;
                Vector3 side = Vector3.Cross(tangent, Mathf.Abs(tangent.y) > 0.9f ? Vector3.right : Vector3.up).normalized;
                Vector3 up = Vector3.Cross(tangent, side);
                float a = v * Mathf.PI * 2f;
                return path(u) + (side * Mathf.Cos(a) + up * Mathf.Sin(a)) * radius(u);
            }, extra, part);
        }

        /// <summary>The source's gem(): a scaled octahedron, turned around Z, then moved.</summary>
        public static void AddGem(VfxMeshBuilder builder, Vector3 center, Vector3 scale, float turn, Vector4 extra = default, float part = 0f)
        {
            float c = Mathf.Cos(turn);
            float s = Mathf.Sin(turn);
            builder.AddOctahedron(1f, p =>
            {
                p = Vector3.Scale(p, scale);
                return new Vector3(p.x * c - p.y * s, p.x * s + p.y * c, p.z) + center;
            }, extra, part);
        }
    }
}
