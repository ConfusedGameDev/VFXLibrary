using System;
using System.Collections.Generic;
using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>
    /// Merges pieces into one mesh, in the source's axes and vertex order. UV1 holds per-piece data
    /// (centres, stream paths), UV2.x the piece's id.
    /// </summary>
    public sealed class VfxMeshBuilder
    {
        // Octahedron faces, as the source's geometry lists them.
        private static readonly Vector3[] OctahedronCorners =
        {
            new Vector3(1f, 0f, 0f), new Vector3(-1f, 0f, 0f), new Vector3(0f, 1f, 0f),
            new Vector3(0f, -1f, 0f), new Vector3(0f, 0f, 1f), new Vector3(0f, 0f, -1f)
        };

        private static readonly int[] OctahedronFaces =
        {
            0, 2, 4, 0, 4, 3, 0, 3, 5, 0, 5, 2, 1, 2, 5, 1, 5, 3, 1, 3, 4, 1, 4, 2
        };

        private readonly List<Vector3> positions = new List<Vector3>();
        private readonly List<Vector3> normals = new List<Vector3>();
        private readonly List<Vector2> uvs = new List<Vector2>();
        private readonly List<Vector4> data = new List<Vector4>();
        private readonly List<Vector2> parts = new List<Vector2>();
        private readonly List<int> indices = new List<int>();

        public int VertexCount => positions.Count;

        public void AddVertex(Vector3 position, Vector2 uv, Vector4 extra = default, float part = 0f)
        {
            positions.Add(position);
            uvs.Add(uv);
            data.Add(extra);
            parts.Add(new Vector2(part, 0f));
        }

        public void AddIndices(params int[] triangle)
        {
            indices.AddRange(triangle);
        }

        /// <summary>A grid of (rows + 1) by (columns + 1) vertices, with the source's patch winding.</summary>
        public void AddPatch(int rows, int columns, Func<float, float, Vector3> point, Vector4 extra = default, float part = 0f)
        {
            int first = VertexCount;
            for (int row = 0; row <= rows; row++)
            {
                for (int column = 0; column <= columns; column++)
                {
                    float u = (float)column / columns;
                    float v = (float)row / rows;
                    AddVertex(point(u, v), new Vector2(u, v), extra, part);
                }
            }

            for (int row = 0; row < rows; row++)
            {
                for (int column = 0; column < columns; column++)
                {
                    int a = first + row * (columns + 1) + column;
                    int b = a + columns + 1;
                    AddIndices(a, b, a + 1, b, b + 1, a + 1);
                }
            }
        }

        /// <summary>A two-vertex-wide strip. UV.x runs along it, UV.y across it.</summary>
        public void AddStrip(int steps, Func<float, int, Vector3> point, Vector4 extra = default, float part = 0f)
        {
            int first = VertexCount;
            for (int step = 0; step <= steps; step++)
            {
                float h = (float)step / steps;
                for (int side = 0; side < 2; side++)
                {
                    AddVertex(point(h, side * 2 - 1), new Vector2(h, side), extra, part);
                }
            }

            for (int step = 0; step < steps; step++)
            {
                int n = first + step * 2;
                AddIndices(n, n + 1, n + 2, n + 1, n + 3, n + 2);
            }
        }

        /// <summary>A surface of (segments + 1) by (sides + 1) vertices, wound outward like the source's lathe shapes.</summary>
        public void AddTube(int segments, int sides, Func<float, float, Vector3> point, Vector4 extra = default, float part = 0f)
        {
            int first = VertexCount;
            for (int segment = 0; segment <= segments; segment++)
            {
                for (int side = 0; side <= sides; side++)
                {
                    float u = (float)segment / segments;
                    float v = (float)side / sides;
                    AddVertex(point(u, v), new Vector2(u, v), extra, part);
                }
            }

            for (int segment = 0; segment < segments; segment++)
            {
                for (int side = 0; side < sides; side++)
                {
                    int n = first + segment * (sides + 1) + side;
                    AddIndices(n, n + 1, n + sides + 1, n + 1, n + sides + 2, n + sides + 1);
                }
            }
        }

        /// <summary>The source's surface(): columns along u, with the opposite vertex order to AddTube.</summary>
        public void AddSurface(int us, int vs, Func<float, float, Vector3> point, Vector4 extra = default, float part = 0f)
        {
            int first = VertexCount;
            for (int i = 0; i <= us; i++)
            {
                for (int j = 0; j <= vs; j++)
                {
                    float u = (float)i / us;
                    float v = (float)j / vs;
                    AddVertex(point(u, v), new Vector2(u, v), extra, part);
                }
            }

            for (int i = 0; i < us; i++)
            {
                for (int j = 0; j < vs; j++)
                {
                    int a = first + i * (vs + 1) + j;
                    int b = a + vs + 1;
                    AddIndices(a, b, a + 1, a + 1, b, b + 1);
                }
            }
        }

        /// <summary>The source's octahedron: eight separate faces, with its spherical UVs.</summary>
        public void AddOctahedron(float radius, Func<Vector3, Vector3> transform = null, Vector4 extra = default, float part = 0f)
        {
            for (int face = 0; face < OctahedronFaces.Length; face += 3)
            {
                Vector3 a = OctahedronCorners[OctahedronFaces[face]];
                Vector3 b = OctahedronCorners[OctahedronFaces[face + 1]];
                Vector3 c = OctahedronCorners[OctahedronFaces[face + 2]];
                float azimuth = Azimuth((a + b + c) / 3f);

                var corners = new[] { a, b, c };
                var faceUvs = new[] { SphereUv(a, azimuth), SphereUv(b, azimuth), SphereUv(c, azimuth) };

                float low = Mathf.Min(faceUvs[0].x, faceUvs[1].x, faceUvs[2].x);
                float high = Mathf.Max(faceUvs[0].x, faceUvs[1].x, faceUvs[2].x);
                int first = VertexCount;

                for (int corner = 0; corner < 3; corner++)
                {
                    Vector2 uv = faceUvs[corner];
                    if (high > 0.9f && low < 0.1f && uv.x < 0.2f)
                    {
                        uv.x += 1f;
                    }

                    Vector3 position = corners[corner] * radius;
                    AddVertex(transform != null ? transform(position) : position, uv, extra, part);
                }

                AddIndices(first, first + 1, first + 2);
            }
        }

        /// <summary>Copies the mesh for each seed, one quad-style instance per entry, into UV1 and UV2.x.</summary>
        public static Mesh Instance(string name, VfxMeshBuilder shape, Vector4[] seeds, Bounds bounds)
        {
            var result = new VfxMeshBuilder();
            for (int i = 0; i < seeds.Length; i++)
            {
                int first = result.VertexCount;
                for (int v = 0; v < shape.positions.Count; v++)
                {
                    result.AddVertex(shape.positions[v], shape.uvs[v], seeds[i], i);
                }

                foreach (int index in shape.indices)
                {
                    result.indices.Add(first + index);
                }
            }

            result.ComputeNormals();
            return result.Build(name, bounds);
        }

        /// <summary>Area-weighted vertex normals by the source's rule, without welding vertices.</summary>
        public void ComputeNormals()
        {
            normals.Clear();
            for (int i = 0; i < positions.Count; i++)
            {
                normals.Add(Vector3.zero);
            }

            for (int i = 0; i < indices.Count; i += 3)
            {
                int a = indices[i];
                int b = indices[i + 1];
                int c = indices[i + 2];
                Vector3 face = Vector3.Cross(positions[c] - positions[b], positions[a] - positions[b]);
                normals[a] += face;
                normals[b] += face;
                normals[c] += face;
            }

            for (int i = 0; i < normals.Count; i++)
            {
                normals[i] = normals[i].normalized;
            }
        }

        public Mesh Build(string name, Bounds bounds)
        {
            var mesh = new Mesh { name = name, indexFormat = UnityEngine.Rendering.IndexFormat.UInt32 };
            mesh.SetVertices(positions);
            mesh.SetUVs(0, uvs);
            mesh.SetUVs(1, data);
            mesh.SetUVs(2, parts);
            if (normals.Count == positions.Count)
            {
                mesh.SetNormals(normals);
            }
            mesh.SetTriangles(indices, 0);
            mesh.bounds = bounds;
            return mesh;
        }

        private static float Azimuth(Vector3 v)
        {
            return Mathf.Atan2(v.z, -v.x);
        }

        private static Vector2 SphereUv(Vector3 v, float faceAzimuth)
        {
            float inclination = Mathf.Atan2(-v.y, Mathf.Sqrt(v.x * v.x + v.z * v.z));
            float u = Azimuth(v) / (2f * Mathf.PI) + 0.5f;
            float w = 1f - (inclination / Mathf.PI + 0.5f);

            if (faceAzimuth < 0f && Mathf.Approximately(u, 1f))
            {
                u -= 1f;
            }

            if (v.x == 0f && v.z == 0f)
            {
                u = faceAzimuth / (2f * Mathf.PI) + 0.5f;
            }

            return new Vector2(u, w);
        }
    }
}
