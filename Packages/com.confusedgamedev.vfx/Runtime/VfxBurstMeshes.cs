using System;
using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Budget and bounds shared by the one-shot bursts.</summary>
    public static class VfxBurstMeshes
    {
        public static readonly Bounds EffectBounds = new Bounds(Vector3.zero, new Vector3(16f, 16f, 16f));

        public static readonly Vector3[] OctahedronVertices =
        {
            new Vector3(1f, 0f, 0f), new Vector3(-1f, 0f, 0f), new Vector3(0f, 1f, 0f),
            new Vector3(0f, -1f, 0f), new Vector3(0f, 0f, 1f), new Vector3(0f, 0f, -1f)
        };

        public static readonly int[] OctahedronFaces = { 0, 2, 4, 0, 4, 3, 0, 3, 5, 0, 5, 2, 1, 2, 5, 1, 5, 3, 1, 3, 4, 1, 4, 2 };

        /// <summary>Adds a flat-shaded polyhedron, every vertex run through map. uv, data and unit are per piece.</summary>
        public static void AddFaces(VfxMeshBuilder builder, Vector3[] vertices, int[] faces, Func<Vector3, Vector3> map, Vector2 uv, Vector4 data, float unit = -1f)
        {
            for (int i = 0; i < faces.Length; i += 3)
            {
                builder.AddFlatTriangle(map(vertices[faces[i]]), map(vertices[faces[i + 1]]), map(vertices[faces[i + 2]]), uv, uv, uv, data, unit);
            }
        }

        /// <summary>A capped flat-shaded prism along +Y, centered on the origin before map.</summary>
        public static void AddPrism(VfxMeshBuilder builder, float radiusTop, float radiusBottom, float height, int sides, Func<Vector3, Vector3> map, Vector2 uv, Vector4 data, float unit = -1f)
        {
            Vector3 Rim(float radius, float y, int i)
            {
                float a = i * Mathf.PI * 2f / sides;
                return map(new Vector3(Mathf.Sin(a) * radius, y, Mathf.Cos(a) * radius));
            }

            Vector3 top = map(new Vector3(0f, height / 2f, 0f));
            Vector3 bottom = map(new Vector3(0f, -height / 2f, 0f));
            for (int i = 0; i < sides; i++)
            {
                Vector3 a = Rim(radiusTop, height / 2f, i);
                Vector3 b = Rim(radiusTop, height / 2f, i + 1);
                Vector3 c = Rim(radiusBottom, -height / 2f, i);
                Vector3 d = Rim(radiusBottom, -height / 2f, i + 1);
                builder.AddFlatTriangle(a, c, b, uv, uv, uv, data, unit);
                builder.AddFlatTriangle(b, c, d, uv, uv, uv, data, unit);
                builder.AddFlatTriangle(a, b, top, uv, uv, uv, data, unit);
                builder.AddFlatTriangle(d, c, bottom, uv, uv, uv, data, unit);
            }
        }

        /// <summary>Instanced flat-shaded tetrahedra.</summary>
        public static Mesh CreateTetrahedra(string name, int count, uint seed)
        {
            var shape = new VfxMeshBuilder();
            Vector3[] corners =
            {
                new Vector3(1f, 1f, 1f).normalized, new Vector3(-1f, -1f, 1f).normalized,
                new Vector3(-1f, 1f, -1f).normalized, new Vector3(1f, -1f, -1f).normalized
            };

            foreach (int corner in new[] { 2, 1, 0, 0, 3, 2, 1, 3, 0, 2, 3, 1 })
            {
                shape.AddVertex(corners[corner], Vector2.zero);
            }

            shape.AddIndices(0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11);
            return VfxMeshBuilder.Instance(name, shape, VfxMeshes.CreateSeeds(count, seed), EffectBounds);
        }

        /// <summary>
        /// The source's split of a particle budget. desired = round(cap * density), less any slots held by
        /// fixed pieces; layers past the first take min(maximum, round(desired * weight)) from last to first,
        /// and the first gets what remains. Holds up to four layers, in allocation order.
        /// </summary>
        public static Vector4 LayerCounts(int cap, int fixedSlots, float density, int[] maxima, float[] weights)
        {
            int desired = Mathf.Max(1, RoundLikeSource(cap * density));
            int remaining = desired - fixedSlots;
            var counts = new Vector4();
            for (int i = maxima.Length - 1; i >= 1; i--)
            {
                int n = Mathf.Min(maxima[i], RoundLikeSource(desired * weights[i]));
                counts[i] = n;
                remaining -= n;
            }
            counts[0] = Mathf.Max(0, remaining);
            return counts;
        }

        // Math.round goes up at .5, Mathf.RoundToInt to the even number.
        private static int RoundLikeSource(float value)
        {
            return Mathf.FloorToInt(value + 0.5f);
        }
    }
}
