using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Breaking Tidal Surge. Defaults match the site's tidal-surge catalog entry.</summary>
    [CreateAssetMenu(fileName = "TidalSurgePreset", menuName = "ConfusedGameDev/VFX/Breaking Tidal Surge Preset")]
    public sealed class TidalSurgePreset : VfxBurstPreset
    {
        public TidalSurgePreset() : base(new Color(0x66 / 255f, 0xcd / 255f, 0xdd / 255f), 3.2f)
        {
        }
    }
}
