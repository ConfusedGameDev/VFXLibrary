using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    public static class PrismParryMeshes
    {
        public const int MaxParticles = 512;

        private const uint Seed = 376667;

        private static readonly int[] Maxima = { 512 };
        private static readonly float[] Weights = { 1f };

        /// <summary>Instances per layer for a density, split the way the source splits its budget.</summary>
        public static Vector4 LayerCounts(float density)
        {
            return VfxBurstMeshes.LayerCounts(MaxParticles, 0, density, Maxima, Weights);
        }

        public static Mesh CreateBody()
        {
            var pieces = new VfxPieceMeshBuilder();
            for (int i = 0; i < Tiles; i++)
            {
                float angle = (i - 1) * Mathf.PI * 2f / 6f;
                float rad = i == 0 ? 0f : 0.98f;
                float front = Mathf.Sqrt(1.18f * 1.18f - rad * rad);
                Vector3 normal = new Vector3(front, Mathf.Cos(angle) * rad, Mathf.Sin(angle) * rad).normalized;
                var center = new Vector3(front - 0.28f, 0.9f + Mathf.Cos(angle) * rad, Mathf.Sin(angle) * rad);
                Quaternion orient = FromUp(normal);
                float phase = i / (Tiles - 1f);

                pieces.AddClosedCylinder(0.51f, 0.17f, 6, v => orient * v, center, new Vector4(phase, angle, 0f, 0.08f), i);
                pieces.EndPiece(center);

                Vector3 inset = center + normal * 0.10f;
                pieces.AddClosedCylinder(0.425f, 0.026f, 6, v => orient * v, inset, new Vector4(phase, angle, 1f, 0.42f), i);
                pieces.EndPiece(inset);
            }

            for (int i = 0; i < 9; i++)
            {
                float a = i * Mathf.PI * 2f / 9f;
                var center = new Vector3(0.8f, 0.9f + Mathf.Cos(a) * 0.25f, Mathf.Sin(a) * 0.25f);
                float cos = Mathf.Cos(a);
                float sin = Mathf.Sin(a);
                VfxBurstMeshes.AddFaces(pieces.Builder, VfxBurstMeshes.OctahedronVertices, VfxBurstMeshes.OctahedronFaces, v =>
                {
                    var s = new Vector3(v.x * 0.07f, v.y * 0.22f, v.z * 0.07f);
                    return new Vector3(s.x, s.y * cos - s.z * sin, s.y * sin + s.z * cos) + center;
                }, Vector2.zero, new Vector4(i / 9f, a, 2f, 0.9f));
                pieces.EndPiece(center);
            }

            AddSegment(pieces, new Vector3(1.01f, 0.54f, 0f), new Vector3(1.01f, 1.26f, 0f), 0.014f, new Vector4(0f, 0f, 3f, 1f));
            AddSegment(pieces, new Vector3(1.01f, 0.83f, -0.31f), new Vector3(1.01f, 0.97f, 0.31f), 0.012f, new Vector4(0f, 0f, 3f, 1f));
            return pieces.Build("PrismParryBody", VfxBurstMeshes.EffectBounds);
        }

        public static Mesh CreateParticles()
        {
            return VfxBurstMeshes.CreateTetrahedra("PrismParryParticles", MaxParticles, Seed);
        }

        private const int Tiles = 4;

        // three's setFromUnitVectors from +Y.
        private static Quaternion FromUp(Vector3 to)
        {
            return new Quaternion(to.z, 0f, -to.x, to.y + 1f).normalized;
        }

        private static void AddSegment(VfxPieceMeshBuilder pieces, Vector3 a, Vector3 b, float radius, Vector4 data)
        {
            Vector3 d = b - a;
            Quaternion orient = FromUp(d.normalized);
            pieces.AddClosedCylinder(radius, d.magnitude, 4, v => orient * v, (a + b) * 0.5f, data, -1f);
            pieces.EndPiece(Vector3.zero);
        }
    }
}
