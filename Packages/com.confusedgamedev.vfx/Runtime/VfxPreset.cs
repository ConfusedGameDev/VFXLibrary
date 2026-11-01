using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>How an effect's clock ends.</summary>
    public enum VfxPlayback
    {
        OneShot,
        Looping
    }

    /// <summary>What happens to an effect once it has finished.</summary>
    public enum VfxEndAction
    {
        None,
        Disable,
        Destroy,
        ReturnToPool
    }

    /// <summary>
    /// Base preset. Holds the lifecycle settings and the controls shared by almost every effect on the
    /// site (see Docs/M0-Discovery.md). Subclasses add effect-specific controls such as quantity.
    /// </summary>
    public abstract class VfxPreset : ScriptableObject
    {
        [Header("Website Controls")]
        public Color color = Color.white;
        [Range(0.25f, 2f)] public float size = 1f;
        [Range(0.25f, 2f)] public float speed = 1f;
        [Range(0.25f, 2f)] public float detail = 1f;
        [Range(0.125f, 1f)] public float density = 0.5f;

        [Header("Lifecycle")]
        public VfxPlayback playback = VfxPlayback.OneShot;
        [Tooltip("Seconds a one-shot effect plays before finishing. Ignored when looping.")]
        [Min(0f)] public float duration = 1f;
        [Tooltip("Seconds of effect time the start-up animation takes.")]
        [Min(0f)] public float startDuration;
        [Tooltip("Seconds of effect time the ending takes after Stop().")]
        [Min(0f)] public float stopDuration = 0.5f;
        public VfxEndAction endAction = VfxEndAction.None;
    }
}
