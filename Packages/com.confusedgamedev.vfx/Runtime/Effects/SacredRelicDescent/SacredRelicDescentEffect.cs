using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>
    /// Sacred Relic Descent. A relic falls into a turning sigil, then five healing waves roll out two seconds apart.
    /// It only draws: no healing, collision or camera work.
    /// </summary>
    public sealed class SacredRelicDescentEffect : VfxBurstEffect
    {
        public const float ImpactTime = 1.35f;
        public const float FirstPulse = 3.35f;
        public const float PulseGap = 2f;
        public const float PulseLength = 1.6f;
        public const int Pulses = 5;

        private static readonly int ClockId = Shader.PropertyToID("_Motion0");
        private static readonly int StateId = Shader.PropertyToID("_Motion1");
        private static readonly int BodyId = Shader.PropertyToID("_Motion2");

        /// <summary>The site's compatibility alias: the same as Stop(), with no collision or healing.</summary>
        public void Hit()
        {
            Stop();
        }

        /// <summary>Seconds into the pulse running at a time, or -1 between them. None start after emission ends.</summary>
        public static float PulseAge(float time, float emitting)
        {
            float found = -1f;
            for (int i = 0; i < Pulses; i++)
            {
                float born = FirstPulse + i * PulseGap;
                float age = time - born;
                if (emitting >= born - 1e-5f && age >= -1e-5f && age < PulseLength - 1e-5f)
                {
                    found = Mathf.Max(0f, age);
                }
            }
            return found;
        }

        public static float WaveRadius(float pulseAge, float spread)
        {
            float left = 1f - pulseAge / PulseLength;
            return pulseAge < 0f ? 0f : 0.12f + (9f * spread - 0.12f) * (1f - left * left);
        }

        protected override Vector4 LayerCounts(float density)
        {
            return SacredRelicDescentMeshes.LayerCounts(density);
        }

        protected override void OnApplyParameters(MaterialPropertyBlock block, VfxPreset parameters)
        {
            base.OnApplyParameters(block, parameters);
            float spread = parameters is SacredRelicDescentPreset preset ? preset.spread : 1f;
            bool cancelled = State == VfxState.Stopping;
            float time = EffectTime;
            float emitting = cancelled ? time - EndProgress * parameters.stopDuration : time;
            float cancel = cancelled ? 1f - Mathf.SmoothStep(0f, 1f, EndProgress) : 1f;
            float impactAge = emitting >= ImpactTime - 1e-5f ? Mathf.Max(0f, time - ImpactTime) : -1f;
            float pulseAge = PulseAge(time, emitting);

            float fall = Mathf.Clamp01((emitting - 1f) / 0.35f);
            float penetration = Mathf.Clamp01((emitting - ImpactTime) / 0.08f);
            float sunk = 1f - penetration;
            float height = 7.5f * (1f - fall * fall) - 0.6f * (1f - sunk * sunk * sunk);
            float bodyFade = Smooth(1f, 1.04f, emitting) * (1f - Smooth(11.35f, 12.2f, time)) * cancel;

            block.SetVector(ClockId, new Vector4(emitting, impactAge, pulseAge, WaveRadius(pulseAge, spread)));
            block.SetVector(StateId, new Vector4(9f * spread, cancel, height, Mathf.Max(0f, -height)));
            block.SetVector(BodyId, new Vector4(bodyFade, 0f, 0f, 0f));
        }

        private static float Smooth(float a, float b, float x)
        {
            float t = Mathf.Clamp01((x - a) / (b - a));
            return t * t * (3f - 2f * t);
        }
    }
}
