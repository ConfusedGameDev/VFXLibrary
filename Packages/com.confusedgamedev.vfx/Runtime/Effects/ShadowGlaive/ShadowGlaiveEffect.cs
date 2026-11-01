using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Afterimage Glaive. A curved blade rolling around the flight axis with three fading afterimages.</summary>
    public sealed class ShadowGlaiveEffect : VfxProjectileEffect
    {
        protected override int MaxParticles => ShadowGlaiveMeshes.MaxParticles;

        protected override Vector3 CurrentContact(VfxPreset parameters)
        {
            return ContactPoint(EffectTime, parameters.size, StartProgress);
        }

        /// <summary>The leading surface in local space, including the start-up deformation.</summary>
        public static Vector3 ContactPoint(float time, float size, float startProgress)
        {
            float x = 0.9f * size;
            float y = -0.2f * size * Mathf.Cos(time * 2.7f);
            float z = 0.2f * size * Mathf.Sin(time * 2.7f);

            if (startProgress < 1f)
            {
                float grow = startProgress * startProgress * (3f - 2f * startProgress);
                float curl = 1f - grow;
                z += Mathf.Sin(x * 4f) * curl * 0.75f;
                x -= curl * 0.5f;
            }

            return new Vector3(z, y, x);
        }
    }
}
