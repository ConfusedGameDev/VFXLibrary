using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Azure Blade Sweep. Defaults match the site's azure-sweep catalog entry.</summary>
    [CreateAssetMenu(fileName = "AzureSweepPreset", menuName = "ConfusedGameDev/VFX/Azure Blade Sweep Preset")]
    public sealed class AzureSweepPreset : VfxBurstPreset
    {
        public AzureSweepPreset() : base(new Color(0x28 / 255f, 0x78 / 255f, 0xff / 255f), 0.85f)
        {
        }
    }
}
