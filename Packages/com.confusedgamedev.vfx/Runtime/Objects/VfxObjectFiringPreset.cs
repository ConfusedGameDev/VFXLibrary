using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>One shot of a weapon or turret. The shot ends by itself and leaves the object in place.</summary>
    [CreateAssetMenu(fileName = "FiringPreset", menuName = "ConfusedGameDev/VFX/Object Firing Preset")]
    public sealed class VfxObjectFiringPreset : VfxPreset
    {
        public VfxObjectFiringPreset()
        {
            playback = VfxPlayback.OneShot;
            startDuration = 0f;
            stopDuration = 0f;
            endAction = VfxEndAction.None;
        }
    }
}
