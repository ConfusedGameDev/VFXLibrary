using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Shattering Frostburst. A one-shot that ends on its own; quantity sets the number of crystals.</summary>
    public sealed class IceShatterEffect : VfxBurstEffect
    {
        protected override Vector4 LayerCounts(float density)
        {
            return IceShatterMeshes.LayerCounts(density);
        }
    }
}
