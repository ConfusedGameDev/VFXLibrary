using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Defaults shared by the one-shot bursts, which end on their own and ignore Stop()'s fade.</summary>
    public abstract class VfxBurstPreset : VfxPreset
    {
        /// <summary>The value of the effect's quantity control, for those that have one.</summary>
        public virtual int Quantity => 1;

        /// <summary>The value of the effect's spread control, for those that have one.</summary>
        public virtual float Spread => 1f;

        protected VfxBurstPreset(Color siteColor, float siteDuration)
        {
            color = siteColor;
            duration = siteDuration;
            stopDuration = 0f;
        }
    }
}
