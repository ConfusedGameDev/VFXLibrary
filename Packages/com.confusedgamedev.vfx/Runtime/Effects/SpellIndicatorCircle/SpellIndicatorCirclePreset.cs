using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Red Circle Spell Indicator. Defaults match the site's spell-indicator-circle catalog entry.</summary>
    [CreateAssetMenu(fileName = "SpellIndicatorCirclePreset", menuName = "ConfusedGameDev/VFX/Red Circle Spell Indicator Preset")]
    public sealed class SpellIndicatorCirclePreset : VfxSpellIndicatorPreset
    {
        public SpellIndicatorCirclePreset() : base(new Color(0xff / 255f, 0x30 / 255f, 0x3e / 255f))
        {
        }
    }
}
