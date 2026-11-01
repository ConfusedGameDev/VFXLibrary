using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Plasma Dart. A charged tip wrapped in electric ribbons, ending in a short branching discharge.</summary>
    public sealed class PlasmaBoltEffect : VfxProjectileEffect
    {
        protected override int MaxParticles => PlasmaBoltMeshes.MaxParticles;

        protected override Vector3 CurrentContact(VfxPreset parameters)
        {
            return ContactPoint(parameters.size, StartProgress);
        }

        /// <summary>The dart's tip in local space, including the start-up deformation.</summary>
        public static Vector3 ContactPoint(float size, float startProgress)
        {
            float forward = 0.85f + 0.85f * size;
            if (startProgress < 1f)
            {
                float grow = startProgress * startProgress * (3f - 2f * startProgress);
                forward *= 1.3f - 0.3f * grow;
            }
            return new Vector3(0f, 0f, forward);
        }
    }
}
