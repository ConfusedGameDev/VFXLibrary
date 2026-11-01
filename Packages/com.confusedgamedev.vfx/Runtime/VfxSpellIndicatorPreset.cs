using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    public enum VfxIndicatorProgress
    {
        /// <summary>Fills by itself over the warning duration.</summary>
        Auto,

        /// <summary>Fills from SetProgress.</summary>
        Manual
    }

    /// <summary>Base of the ground warnings. They run on their own clock, so speed has no effect on the fill.</summary>
    public abstract class VfxSpellIndicatorPreset : VfxPreset
    {
        [Header("Indicator")]
        [Tooltip("Radius in scene units. This replaces size, which only reaches 2.")]
        [Range(0.25f, 20f)] public float radius = 3f;

        [Tooltip("Seconds to fill in Auto mode. Keep gameplay timing in the game: finishing only means invisible.")]
        [Range(0.1f, 30f)] public float warningDuration = 2f;

        public VfxIndicatorProgress progressMode = VfxIndicatorProgress.Auto;

        protected VfxSpellIndicatorPreset(Color siteColor)
        {
            color = siteColor;
            playback = VfxPlayback.Looping;
            duration = 2.15f;
            stopDuration = 0.12f;
        }

        /// <summary>The full opening of the shape.</summary>
        public virtual float AngleDegrees => 360f;
    }
}
