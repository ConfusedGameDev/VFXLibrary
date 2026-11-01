using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Lightning Arc Burst. Defaults match the site's energy-burst catalog entry.</summary>
    [CreateAssetMenu(fileName = "EnergyBurstPreset", menuName = "ConfusedGameDev/VFX/Energy Burst Preset")]
    public sealed class EnergyBurstPreset : VfxPreset
    {
        [Header("Energy Burst")]
        [Range(1, 24)] public int quantity = 12;

        public EnergyBurstPreset()
        {
            color = new Color(0x28 / 255f, 0x78 / 255f, 0xff / 255f);
            duration = 2.8f;
            stopDuration = 0f;
        }
    }
}
