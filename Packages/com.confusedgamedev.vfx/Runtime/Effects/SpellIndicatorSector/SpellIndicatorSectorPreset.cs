using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Red Sector Spell Indicator. Defaults match the site's spell-indicator-sector catalog entry.</summary>
    [CreateAssetMenu(fileName = "SpellIndicatorSectorPreset", menuName = "ConfusedGameDev/VFX/Red Sector Spell Indicator Preset")]
    public sealed class SpellIndicatorSectorPreset : VfxSpellIndicatorPreset
    {
        [Tooltip("Full opening of the sector, around its forward axis.")]
        [Range(5f, 360f)] public float angleDegrees = 90f;

        public SpellIndicatorSectorPreset() : base(new Color(0xff / 255f, 0x30 / 255f, 0x3e / 255f))
        {
        }

        public override float AngleDegrees => angleDegrees;
    }
}
