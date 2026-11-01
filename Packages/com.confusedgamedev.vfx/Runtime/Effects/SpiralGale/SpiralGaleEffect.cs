using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Spiraling Wind Spear. Seven twisting ribbons of wind form a spear, unwinding forward on impact.</summary>
    public sealed class SpiralGaleEffect : VfxProjectileEffect
    {
        protected override int MaxParticles => SpiralGaleMeshes.MaxParticles;

        protected override Vector3 CurrentContact(VfxPreset parameters)
        {
            return ContactPoint(parameters.size);
        }

        /// <summary>The leading surface in local space, including the start-up deformation.</summary>
        public static Vector3 ContactPoint(float size)
        {
            return new Vector3(0f, 0f, 1.11f * size);
        }
    }
}
