using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>
    /// Base of the ground warnings: a shape that fills, flashes its edge once, and vanishes.
    /// It only draws. It triggers no damage, and Stop() cancels it with a fade and no flash.
    /// </summary>
    public abstract class VfxSpellIndicatorEffect : VfxEffect
    {
        private const float CompleteSeconds = 0.15f;
        private const float FlashSeconds = 0.06f;
        private const float FlowPeriod = Mathf.PI * 2f / 2.6f;

        private static readonly int ShapeId = Shader.PropertyToID("_Motion0");
        private static readonly int EdgeColorId = Shader.PropertyToID("_Motion1");
        private static readonly int FlowId = Shader.PropertyToID("_Motion2");

        private float clock;
        private float endAge;
        private bool completing;

        /// <summary>0 to 1, how much of the shape has filled.</summary>
        public float Progress { get; private set; }

        /// <summary>Sets the fill in Manual mode. Reaching 1 starts the ending; an ending cannot be undone.</summary>
        public void SetProgress(float value)
        {
            if (State != VfxState.Playing || completing || float.IsNaN(value)
                || !(ActiveParameters is VfxSpellIndicatorPreset preset) || preset.progressMode != VfxIndicatorProgress.Manual)
            {
                return;
            }

            Progress = Mathf.Clamp01(value);
            completing = Progress >= 1f;
            ApplyParameters();
        }

        /// <summary>The edge color the site derives from a linear color, with the hue slightly turned.</summary>
        public static Vector4 EdgeColor(Color linear)
        {
            float max = Mathf.Max(linear.r, linear.g, linear.b);
            float min = Mathf.Min(linear.r, linear.g, linear.b);
            float lightness = (min + max) * 0.5f;
            float hue = 0f;
            float saturation = 0f;
            if (max > min)
            {
                float delta = max - min;
                saturation = lightness <= 0.5f ? delta / (max + min) : delta / (2f - max - min);
                if (max == linear.r)
                {
                    hue = (linear.g - linear.b) / delta + (linear.g < linear.b ? 6f : 0f);
                }
                else if (max == linear.g)
                {
                    hue = (linear.b - linear.r) / delta + 2f;
                }
                else
                {
                    hue = (linear.r - linear.g) / delta + 4f;
                }

                hue /= 6f;
            }

            hue = (hue + 0.045f) % 1f;
            saturation *= 0.86f;
            lightness = Mathf.Min(0.68f, Mathf.Max(0.52f, lightness));
            float p = lightness <= 0.5f ? lightness * (1f + saturation) : lightness + saturation - lightness * saturation;
            float q = 2f * lightness - p;
            return new Vector4(HueChannel(q, p, hue + 1f / 3f), HueChannel(q, p, hue), HueChannel(q, p, hue - 1f / 3f), 1f);
        }

        protected override void OnPlay()
        {
            clock = 0f;
            endAge = 0f;
            completing = false;
            Progress = 0f;
        }

        protected override void OnTick(float deltaTime)
        {
            if (!(deltaTime >= 0f) || float.IsInfinity(deltaTime) || !(ActiveParameters is VfxSpellIndicatorPreset preset))
            {
                return;
            }

            float remaining = deltaTime;
            if (State == VfxState.Stopping)
            {
                clock += remaining;
                return;
            }

            if (!completing)
            {
                if (preset.progressMode == VfxIndicatorProgress.Auto)
                {
                    float advance = Mathf.Min(remaining, Mathf.Max(0f, preset.warningDuration - clock));
                    clock += advance;
                    remaining -= advance;
                    Progress = Mathf.Min(1f, clock / preset.warningDuration);
                    if (clock >= preset.warningDuration - 1e-5f)
                    {
                        clock = preset.warningDuration;
                        Progress = 1f;
                        completing = true;
                    }
                }
                else
                {
                    clock += remaining;
                    remaining = 0f;
                }
            }

            if (completing)
            {
                float advance = Mathf.Min(remaining, Mathf.Max(0f, CompleteSeconds - endAge));
                clock += advance;
                endAge += advance;
                if (endAge >= CompleteSeconds - 1e-5f)
                {
                    Stop(true);
                }
            }
        }

        protected override void OnApplyParameters(MaterialPropertyBlock block, VfxPreset parameters)
        {
            if (!(parameters is VfxSpellIndicatorPreset preset))
            {
                return;
            }

            float flash = completing && endAge < FlashSeconds ? 1f - 0.35f * endAge / FlashSeconds : 0f;
            float opacity = completing ? Mathf.Max(0f, 1f - Mathf.Max(0f, endAge - FlashSeconds) / 0.09f) : 1f;
            block.SetVector(ShapeId, new Vector4(Progress, preset.AngleDegrees * Mathf.PI / 360f, opacity * Fade, flash));
            block.SetVector(EdgeColorId, EdgeColor(preset.color.linear));
            block.SetVector(FlowId, new Vector4(clock % FlowPeriod, preset.radius, 0f, 0f));
        }

        private static float HueChannel(float p, float q, float t)
        {
            t = t < 0f ? t + 1f : t > 1f ? t - 1f : t;
            if (t < 1f / 6f)
            {
                return p + (q - p) * 6f * t;
            }

            if (t < 0.5f)
            {
                return q;
            }

            return t < 2f / 3f ? p + (q - p) * 6f * (2f / 3f - t) : p;
        }
    }
}
