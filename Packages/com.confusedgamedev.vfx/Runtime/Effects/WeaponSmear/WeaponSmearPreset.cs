using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Gleaming Blade Trail. Defaults match the site's weapon-smear catalog entry.</summary>
    [CreateAssetMenu(fileName = "WeaponSmearPreset", menuName = "ConfusedGameDev/VFX/Gleaming Blade Trail Preset")]
    public sealed class WeaponSmearPreset : VfxPreset
    {
        public WeaponSmearPreset()
        {
            color = new Color(0x28 / 255f, 0x78 / 255f, 0xff / 255f);
            playback = VfxPlayback.Looping;
            duration = 4f;
            startDuration = 0.001f;
            stopDuration = VfxBladeTrailEffect.Lifetime;
        }
    }
}
