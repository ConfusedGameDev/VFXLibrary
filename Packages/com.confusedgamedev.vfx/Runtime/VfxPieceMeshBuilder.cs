using System;
using System.Collections.Generic;
using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>
    /// Builds a merged mesh of solid pieces that deform around their own centres. Wraps VfxMeshBuilder
    /// and adds the source's aCenter attribute in UV3.
    /// </summary>
    public sealed class VfxPieceMeshBuilder
    {
        private readonly List<Vector3> centers = new List<Vector3>();

        public VfxMeshBuilder Builder { get; } = new VfxMeshBuilder();

        /// <summary>Gives every vertex added since the last call this centre.</summary>
        public void EndPiece(Vector3 center)
        {
            while (centers.Count < Builder.VertexCount)
            {
                centers.Add(center);
            }
        }

        public Mesh Build(string name, Bounds bounds)
        {
            Mesh mesh = Builder.Build(name, bounds);
            mesh.SetUVs(3, centers);
            return mesh;
        }

        /// <summary>The source's capped CylinderGeometry, with its smooth sides and flat caps.</summary>
        public void AddClosedCylinder(float radius, float height, int sides, Func<Vector3, Vector3> turn, Vector3 offset, Vector4 data, float unit)
        {
            Builder.AddCylinder(radius, radius, height, sides, 1, turn, offset, data, unit);
            AddCap(radius, height / 2f, sides, turn, offset, data, unit);
            AddCap(radius, -height / 2f, sides, turn, offset, data, unit);
        }

        private void AddCap(float radius, float y, int sides, Func<Vector3, Vector3> turn, Vector3 offset, Vector4 data, float unit)
        {
            Vector3 normal = turn(new Vector3(0f, Mathf.Sign(y), 0f));
            int hub = Builder.VertexCount;
            Builder.AddLitVertex(turn(new Vector3(0f, y, 0f)) + offset, normal, Vector2.zero, data, unit);
            for (int i = 0; i <= sides; i++)
            {
                float a = i * Mathf.PI * 2f / sides;
                Builder.AddLitVertex(turn(new Vector3(Mathf.Sin(a) * radius, y, Mathf.Cos(a) * radius)) + offset, normal, Vector2.zero, data, unit);
            }

            for (int i = 0; i < sides; i++)
            {
                Builder.AddIndices(hub, hub + 1 + i, hub + 2 + i);
            }
        }
    }
}
