using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Sixfold Frost Sigil. Defaults match the site's frost-field catalog entry.</summary>
    [CreateAssetMenu(fileName = "FrostFieldPreset", menuName = "ConfusedGameDev/VFX/Sixfold Frost Sigil Preset")]
    public sealed class FrostFieldPreset : VfxGroundPreset
    {
        public FrostFieldPreset() : base(new Color(0x9b / 255f, 0xdf / 255f, 0xff / 255f))
        {
        }
    }
}
