using System.Collections.Generic;
using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Mesh helpers shared by effects. Shaders do the shaping, so meshes mostly carry IDs and seeds.</summary>
    public static class VfxMeshes
    {
        /// <summary>
        /// Same generator as the source, so particles land where they do on the site. The source offsets
        /// the seed by 311 for each particle layer an effect allocates before this one.
        /// </summary>
        public static Vector4[] CreateSeeds(int count, uint seed, int layerIndex = 0)
        {
            var seeds = new Vector4[count];
            uint state = unchecked(seed + (uint)layerIndex * 311u);
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

        /// <summary>A subdivided square in XY, for flat layers that deform during their lifecycle.</summary>
        public static Mesh CreateGrid(string name, float width, int segments, Bounds bounds)
        {
            var positions = new List<Vector3>();
            var uvs = new List<Vector2>();
            var indices = new List<int>();

            for (int y = 0; y <= segments; y++)
            {
                for (int x = 0; x <= segments; x++)
                {
                    var uv = new Vector2((float)x / segments, (float)y / segments);
                    positions.Add(new Vector3((uv.x - 0.5f) * width, (uv.y - 0.5f) * width, 0f));
                    uvs.Add(uv);
                }
            }

            for (int y = 0; y < segments; y++)
            {
                for (int x = 0; x < segments; x++)
                {
                    int corner = y * (segments + 1) + x;
                    int above = corner + segments + 1;
                    indices.Add(corner);
                    indices.Add(above);
                    indices.Add(corner + 1);
                    indices.Add(above);
                    indices.Add(above + 1);
                    indices.Add(corner + 1);
                }
            }

            var mesh = new Mesh { name = name };
            mesh.SetVertices(positions);
            mesh.SetUVs(0, uvs);
            mesh.SetTriangles(indices, 0);
            mesh.bounds = bounds;
            return mesh;
        }

        /// <summary>
        /// Instanced quads baked into one mesh. Each has its index in UV2.x, for shaders to collapse
        /// the ones past their count, and its seed in UV1 when seeds are given.
        /// </summary>
        public static Mesh CreateQuads(string name, int count, Bounds bounds, float width = 1f, int segments = 1, Vector4[] seeds = null)
        {
            var positions = new List<Vector3>();
            var uvs = new List<Vector2>();
            var ids = new List<Vector2>();
            var extras = new List<Vector4>();
            var indices = new List<int>();

            for (int i = 0; i < count; i++)
            {
                int first = positions.Count;
                for (int v = 0; v <= 1; v++)
                {
                    for (int u = 0; u <= segments; u++)
                    {
                        float x = (float)u / segments;
                        positions.Add(new Vector3((x - 0.5f) * width, (v - 0.5f) * width, 0f));
                        uvs.Add(new Vector2(x, v));
                        ids.Add(new Vector2(i, 0f));
                        if (seeds != null)
                        {
                            extras.Add(seeds[i]);
                        }
                    }
                }

                for (int u = 0; u < segments; u++)
                {
                    int corner = first + u;
                    int above = corner + segments + 1;
                    indices.Add(corner);
                    indices.Add(above);
                    indices.Add(corner + 1);
                    indices.Add(above);
                    indices.Add(above + 1);
                    indices.Add(corner + 1);
                }
            }

            var mesh = new Mesh { name = name, indexFormat = UnityEngine.Rendering.IndexFormat.UInt32 };
            mesh.SetVertices(positions);
            mesh.SetUVs(0, uvs);
            mesh.SetUVs(2, ids);
            if (seeds != null)
            {
                mesh.SetUVs(1, extras);
            }
            mesh.SetTriangles(indices, 0);
            mesh.bounds = bounds;
            return mesh;
        }
    }
}
