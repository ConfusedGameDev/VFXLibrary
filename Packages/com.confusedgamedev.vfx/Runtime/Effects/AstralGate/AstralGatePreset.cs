using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Gate of Astral Tracery. Defaults match the site's astral-gate catalog entry.</summary>
    [CreateAssetMenu(fileName = "AstralGatePreset", menuName = "ConfusedGameDev/VFX/Gate of Astral Tracery Preset")]
    public sealed class AstralGatePreset : VfxGroundPreset
    {
        public AstralGatePreset() : base(new Color(0xc1 / 255f, 0xb8 / 255f, 0xff / 255f))
        {
            startDuration = 0.8f;
            stopDuration = 0.8f;
        }
    }
}
