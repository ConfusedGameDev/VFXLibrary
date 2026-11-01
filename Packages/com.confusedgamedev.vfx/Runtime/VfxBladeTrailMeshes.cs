using System.Collections.Generic;
using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    public static class VfxBladeTrailMeshes
    {
        /// <summary>
        /// The trail's strip. UV.x is the slot along it and UV.y runs from blade root to tip. Effects
        /// write its positions and ages every frame, so the baked copy only holds the layout.
        /// </summary>
        public static Mesh CreateRibbon(string name)
        {
            const int Slots = VfxBladeTrailEffect.Capacity;
            var positions = new Vector3[Slots * 2];
            var uvs = new Vector2[Slots * 2];
            var ages = new Vector2[Slots * 2];
            var indices = new List<int>((Slots - 1) * 6);
            for (int i = 0; i < Slots; i++)
            {
                float u = i / (Slots - 1f);
                uvs[i * 2] = new Vector2(u, 0f);
                uvs[i * 2 + 1] = new Vector2(u, 1f);
                if (i < Slots - 1)
                {
                    int a = i * 2;
                    indices.AddRange(new[] { a, a + 1, a + 2, a + 1, a + 3, a + 2 });
                }
            }

            var mesh = new Mesh { name = name };
            mesh.SetVertices(positions);
            mesh.SetUVs(0, uvs);
            mesh.SetUVs(1, ages);
            mesh.SetTriangles(indices, 0);
            return mesh;
        }
    }
}
