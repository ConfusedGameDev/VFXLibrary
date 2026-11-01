using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    public static class PrismGuardMeshes
    {
        public const int MaxParticles = 512;

        private const uint Seed = 367480;

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
            return pieces.Build("PrismGuardBody", VfxBurstMeshes.EffectBounds);
        }

        public static Mesh CreateParticles()
        {
            return VfxBurstMeshes.CreateTetrahedra("PrismGuardParticles", MaxParticles, Seed);
        }

        private const int Tiles = 7;

        // three's setFromUnitVectors from +Y.
        private static Quaternion FromUp(Vector3 to)
        {
            return new Quaternion(to.z, 0f, -to.x, to.y + 1f).normalized;
        }
    }
}
