using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>
    /// Base of the blade sweeps: an arc around the origin whose head runs nearly a full turn. Exposes where
    /// the head is, so a weapon can be held to it and draw the arc. Matches the head in the sweep shaders.
    /// </summary>
    public abstract class VfxSweepEffect : VfxBurstEffect
    {
        private const float HeadStartLength = 0.012f;
        private const float HeadRiseStart = 0.08f;
        private const float HeadRiseEnd = 0.32f;
        private const float StartAngle = -2.35f;
        private const float ArcAngle = 5.235987756f;
        private const float Height = 1f;

        /// <summary>Local point the arc turns around.</summary>
        public Vector3 Center => Vector3.up * (Height * ActiveParameters.size);

        /// <summary>Local yaw of the head before it moves, in degrees.</summary>
        public float StartYaw => YawAt(0f);

        /// <summary>Local yaw of the head right now, in degrees.</summary>
        public float HeadYaw => YawAt(EffectTime);

        private static float YawAt(float time)
        {
            float rise = Mathf.Clamp01((time - HeadRiseStart) / (HeadRiseEnd - HeadRiseStart));
            float head = Mathf.Lerp(HeadStartLength, 1f, rise * rise * (3f - 2f * rise));
            return (StartAngle + head * ArcAngle) * Mathf.Rad2Deg;
        }
    }
}
