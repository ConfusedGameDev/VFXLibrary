using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Healing Sigil. Defaults match the site's healing-field catalog entry.</summary>
    [CreateAssetMenu(fileName = "HealingFieldPreset", menuName = "ConfusedGameDev/VFX/Healing Sigil Preset")]
    public sealed class HealingFieldPreset : VfxGroundPreset
    {
        public HealingFieldPreset() : base(new Color(0x86 / 255f, 0xe9 / 255f, 0xb2 / 255f))
        {
        }
    }
}
