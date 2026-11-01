using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Lightning Arc Burst. A one-shot that ends on its own; quantity sets the number of main arcs.</summary>
    public sealed class EnergyBurstEffect : VfxEffect
    {
        private static readonly int QuantityId = Shader.PropertyToID("_Quantity");
        private static readonly int LayerCountsId = Shader.PropertyToID("_LayerCounts");

        protected override void OnApplyParameters(MaterialPropertyBlock block, VfxPreset parameters)
        {
            var burst = (EnergyBurstPreset)parameters;
            Vector3Int counts = EnergyBurstMeshes.LayerCounts(burst.density);
            block.SetFloat(QuantityId, burst.quantity);
            block.SetVector(LayerCountsId, new Vector4(counts.x, counts.y, counts.z, 0f));
        }
    }
}
