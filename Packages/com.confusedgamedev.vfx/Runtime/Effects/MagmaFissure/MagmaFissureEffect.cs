using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Molten Vein Fissure. A one-shot that ends on its own; quantity sets the rock pairs along the crack.</summary>
    public sealed class MagmaFissureEffect : VfxBurstEffect
    {
        protected override Vector4 LayerCounts(float density)
        {
            return MagmaFissureMeshes.LayerCounts(density);
        }
    }
}
