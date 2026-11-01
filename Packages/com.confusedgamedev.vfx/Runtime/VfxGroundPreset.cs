using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Defaults shared by the ground effects, which run until Stop().</summary>
    public abstract class VfxGroundPreset : VfxPreset
    {
        /// <summary>The value of the effect's quantity control, for those that have one.</summary>
        public virtual int Quantity => 0;

        protected VfxGroundPreset(Color siteColor)
        {
            color = siteColor;
            playback = VfxPlayback.Looping;
            duration = 5f;
            startDuration = 0.7f;
            stopDuration = 1f;
        }
    }
}
