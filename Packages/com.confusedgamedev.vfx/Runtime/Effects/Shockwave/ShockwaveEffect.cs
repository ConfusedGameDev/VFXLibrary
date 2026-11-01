using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Dust-Raising Shockwave. A one-shot whose last 1.26 seconds of dust break up, as on the site.</summary>
    public sealed class ShockwaveEffect : VfxBurstEffect
    {
        protected override float EndingSeconds => 1.26f;

        protected override Vector4 LayerCounts(float density)
        {
            return ShockwaveMeshes.LayerCounts(density);
        }
    }
}
