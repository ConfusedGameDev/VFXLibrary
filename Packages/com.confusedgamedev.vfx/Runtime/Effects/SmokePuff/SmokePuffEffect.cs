using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Dispersing Smoke Puff. A one-shot that swells fast and clears on its own.</summary>
    public sealed class SmokePuffEffect : VfxBurstEffect
    {
        protected override Vector4 LayerCounts(float density)
        {
            return SmokePuffMeshes.LayerCounts(density);
        }
    }
}
