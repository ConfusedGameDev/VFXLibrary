using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Azure Blade Sweep. A blue-white arc of nearly a full turn sweeps out, holds, then its tail catches the head. It ends on its own.</summary>
    public sealed class AzureSweepEffect : VfxBurstEffect
    {
        protected override Vector4 LayerCounts(float density)
        {
            return AzureSweepMeshes.LayerCounts(density);
        }
    }
}
