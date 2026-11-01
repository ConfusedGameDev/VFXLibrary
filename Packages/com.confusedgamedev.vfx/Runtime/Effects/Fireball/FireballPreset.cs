using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Blazing Fireball. Defaults match the site's fireball catalog entry.</summary>
    [CreateAssetMenu(fileName = "FireballPreset", menuName = "ConfusedGameDev/VFX/Fireball Preset")]
    public sealed class FireballPreset : VfxPreset
    {
        public FireballPreset()
        {
            color = new Color(0xff / 255f, 0x82 / 255f, 0x3e / 255f);
            playback = VfxPlayback.Looping;
            startDuration = 0.35f;
            stopDuration = 0.8f;
        }
    }
}
