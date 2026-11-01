using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Blazing Fireball. Flight, Hit and the impact layers live in VfxProjectileEffect.</summary>
    public sealed class FireballEffect : VfxProjectileEffect
    {
        protected override int MaxParticles => FireballMeshes.MaxParticles;

        protected override Vector3 CurrentContact(VfxPreset parameters)
        {
            return ContactPoint(EffectTime, parameters.size, StartProgress);
        }

        /// <summary>The fireball's leading surface in local space, including the start-up deformation.</summary>
        public static Vector3 ContactPoint(float time, float size, float startProgress)
        {
            // Source axes: +X is forward.
            float x = 0.65f + (0.46f + Mathf.Sin(time * 4.1f) * 0.035f) * size;
            float y = Mathf.Sin(5f + time * 3f) * 0.03f * size;
            float z = Mathf.Cos(7f + time * 2.7f) * 0.03f * size;

            if (startProgress < 1f)
            {
                float grow = startProgress * startProgress * (3f - 2f * startProgress);
                float curl = 1f - grow;
                y *= 0.22f + 0.78f * grow;
                z *= 0.22f + 0.78f * grow;
                x = (x * 0.38f - 0.16f) * (1f - grow) + x * grow;
                y += Mathf.Sin(x * 4.5f + startProgress * 7f) * curl * 0.15f;
            }

            return new Vector3(z, y, x);
        }

        protected override int ParticleCount(VfxPreset parameters)
        {
            int count = base.ParticleCount(parameters);

            // The impact borrows these ember slots while its puffs are on screen.
            return Impacted && State == VfxState.Stopping ? Mathf.Max(0, count - FireballMeshes.ImpactPuffs) : count;
        }
    }
}
