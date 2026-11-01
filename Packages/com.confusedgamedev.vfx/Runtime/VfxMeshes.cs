using System.Collections.Generic;
using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Mesh helpers shared by effects. Shaders do the shaping, so meshes mostly carry IDs and seeds.</summary>
    public static class VfxMeshes
    {
        // Holds a projectile's longest reach at size 2, including the ending's stretch and impact.
        public static readonly Bounds ProjectileBounds = new Bounds(new Vector3(0f, 0f, -1f), new Vector3(9f, 9f, 13f));

        // Holds a beam at its base length and size 2, including the end flares. The root's scale carries it to any length.
        public static readonly Bounds BeamBounds = new Bounds(Vector3.zero, new Vector3(6f, 6f, 9f));

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

        /// <summary>The newer projectiles' fixed-length ribbon trail. Each ribbon's phase goes in UV1.x.</summary>
        public static Mesh CreateSchoolTrail(string name, int ribbons)
        {
            var builder = new VfxMeshBuilder();
            for (int k = 0; k < ribbons; k++)
            {
                int ribbon = k;
                builder.AddSurface(24, 2, (u, v) =>
                {
                    float a = ribbon * Mathf.PI * 0.5f + u * 3f;
                    float r = (1f - u) * 0.3f;
                    float w = Mathf.Sin(u * Mathf.PI) * 0.065f * (v * 2f - 1f);
                    return new Vector3(-u * 2.8f, Mathf.Cos(a) * r + w, Mathf.Sin(a) * r + w * 0.3f);
                }, new Vector4(k, 0f, 0f, 0f));
            }
            return builder.Build(name, ProjectileBounds);
        }

        /// <summary>An open tube along the beam, in source axes. UV.x runs around it, UV.y from source to target.</summary>
        public static Mesh CreateBeamTube(string name, float radius, int sides, int segments)
        {
            var builder = new VfxMeshBuilder();
            builder.AddPatch(segments, sides, (u, v) =>
            {
                float a = u * Mathf.PI * 2f;
                return new Vector3((v - 0.5f) * 4.8f, -Mathf.Sin(a) * radius, Mathf.Cos(a) * radius);
            });
            return builder.Build(name, BeamBounds);
        }

        /// <summary>A billboard quad per end. UV1 holds the end's x and its role, 0 at the source and 1 at the target.</summary>
        public static Mesh CreateBeamFlares(string name, float sourceWidth, float targetWidth)
        {
            var builder = new VfxMeshBuilder();
            builder.AddPatch(1, 1, (u, v) => new Vector3((u - 0.5f) * sourceWidth, (v - 0.5f) * sourceWidth, 0f), new Vector4(-2.4f, 0f, 0f, 0f));
            builder.AddPatch(1, 1, (u, v) => new Vector3((u - 0.5f) * targetWidth, (v - 0.5f) * targetWidth, 0f), new Vector4(2.4f, 1f, 0f, 0f));
            return builder.Build(name, BeamBounds);
        }

        /// <summary>A quad across the beam at each end, in source axes. UV1.x holds the end, -1 or 1.</summary>
        public static Mesh CreateBeamDiscs(string name)
        {
            var builder = new VfxMeshBuilder();
            builder.AddPatch(1, 1, (u, v) => new Vector3(-2.4f, v - 0.5f, 0.5f - u), new Vector4(-1f, 0f, 0f, 0f));
            builder.AddPatch(1, 1, (u, v) => new Vector3(2.4f, (v - 0.5f) * 1.3f, (0.5f - u) * 1.3f), new Vector4(1f, 0f, 0f, 0f));
            return builder.Build(name, BeamBounds);
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
