using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Frostcrystal Dart. A faceted crystal cluster shedding frost, shattering into shards on impact.</summary>
    public sealed class IceShardEffect : VfxProjectileEffect
    {
        protected override int MaxParticles => IceShardMeshes.MaxParticles;

        protected override Vector3 CurrentContact(VfxPreset parameters)
        {
            return ContactPoint(parameters.size, StartProgress);
        }

        /// <summary>The cluster's tip in local space, including the start-up assembly.</summary>
        public static Vector3 ContactPoint(float size, float startProgress)
        {
            float forward = 0.85f + 0.93f * size;
            if (startProgress < 1f)
            {
                float grow = startProgress * startProgress * (3f - 2f * startProgress);
                forward -= (1f - grow) * (0.2f + TipAssemble);
            }
            return new Vector3(0f, 0f, forward);
        }

        // The stage's assembly term on the flight axis, where the tip sits.
        private const float TipAssemble = 10f * 0.028f;
    }
}
