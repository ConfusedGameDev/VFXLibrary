using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Flame-Etched Ground. Defaults match the site's burning-ground catalog entry.</summary>
    [CreateAssetMenu(fileName = "BurningGroundPreset", menuName = "ConfusedGameDev/VFX/Flame-Etched Ground Preset")]
    public sealed class BurningGroundPreset : VfxGroundPreset
    {
        public BurningGroundPreset() : base(new Color(0xff / 255f, 0x91 / 255f, 0x4a / 255f))
        {
        }
    }
}
