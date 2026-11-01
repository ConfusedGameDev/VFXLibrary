using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Breaking Tidal Surge. A one-shot that ends on its own. The wave travels along +X.</summary>
    public sealed class TidalSurgeEffect : VfxBurstEffect
    {
        protected override Vector4 LayerCounts(float density)
        {
            return TidalSurgeMeshes.LayerCounts(density);
        }
    }
}
