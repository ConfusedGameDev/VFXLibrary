using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Crystal-Toothed Ice Wheel. A spinning ring of ice with nine crystal teeth, breaking into curved shards.</summary>
    public sealed class FrostWheelEffect : VfxProjectileEffect
    {
        protected override int MaxParticles => FrostWheelMeshes.MaxParticles;

        protected override Vector3 CurrentContact(VfxPreset parameters)
        {
            return ContactPoint(EffectTime, parameters.size, StartProgress);
        }

        /// <summary>The leading surface in local space, including the start-up deformation.</summary>
        public static Vector3 ContactPoint(float time, float size, float startProgress)
        {
            float x = 0.81f * size;
            float y = 0f;
            float z = 0f;

            // The foremost tooth, or the outer rim.
            for (int i = 0; i < 9; i++)
            {
                float a = i * Mathf.PI * 2f / 9f - time * 4f;
                float r = 0.99f + i % 3 * 0.035f;
                float tooth = Mathf.Cos(a) * r * size;
                if (tooth > x)
                {
                    x = tooth;
                    y = Mathf.Sin(a) * r * size;
                    z = 0.02f * size;
                }
            }

            float turn = -0.15f * Mathf.Sin(time * 2f);
            float across = y;
            y = across * Mathf.Cos(turn);
            z += across * Mathf.Sin(turn);

            if (startProgress < 1f)
            {
                float grow = startProgress * startProgress * (3f - 2f * startProgress);
                float curl = 1f - grow;
                float assemble = Mathf.Ceil((Mathf.Atan2(z, y) + Mathf.PI) * 3f) * 0.028f;
                y *= 1f + curl * (0.8f + assemble);
                z *= 1f + curl * (0.8f + assemble);
                x -= curl * (0.2f + assemble);
            }

            return new Vector3(z, y, x);
        }
    }
}
