using System;
using System.Collections.Generic;
using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    public enum ImpactFramePose
    {
        Silhouette,
        Tear,
        Burst,
        Cut,
        Echo,
        Clean,
        Release,
        Detonate,
        Shock
    }

    public enum ImpactFrameMode
    {
        Monochrome,
        Inverted,

        /// <summary>Passes the camera image through.</summary>
        Original
    }

    [Serializable]
    public struct ImpactFrameStage
    {
        public ImpactFramePose pose;
        public ImpactFrameMode mode;
        [Min(0.001f)] public float durationMs;
        [Range(0f, 1f)] public float intensity;

        public ImpactFrameStage(ImpactFramePose pose, ImpactFrameMode mode, float durationMs, float intensity = 1f)
        {
            this.pose = pose;
            this.mode = mode;
            this.durationMs = durationMs;
            this.intensity = intensity;
        }
    }

    /// <summary>
    /// Fires the impact frame: a 400 ms black and white ink sequence over the whole camera image.
    /// Needs ImpactFrameFeature on the renderer. Call Fire on a confirmed hit. It does not freeze the
    /// game, and runs on unscaled time, so it keeps going through a hit stop.
    /// </summary>
    [ExecuteAlways]
    [DisallowMultipleComponent]
    public sealed class ImpactFrameTrigger : MonoBehaviour
    {
        private static readonly List<ImpactFrameTrigger> Enabled = new List<ImpactFrameTrigger>();

        private static readonly Vector4[][] Layouts =
        {
            new[] { Star(-0.5f, 0.30f, 1.25f, 2f), Star(0.28f, 0.22f, 0.45f, 0.55f), Star(-0.12f, -0.34f, 0.45f, 0.55f), default },
            new[] { Star(-0.5f, 0.32f, 1.25f, 2f), Star(0.36f, 0.35f, 0.45f, 0.55f), Star(-0.12f, -0.36f, 0.45f, 0.55f), default },
            new[] { Star(-0.48f, -0.27f, 1.25f, 2f), Star(0.34f, 0.27f, 0.65f, 0.8f), Star(-0.19f, 0.38f, 0.45f, 0.55f), Star(0.30f, -0.23f, 0.45f, 0.55f) },
            new[] { Star(0.34f, 0.28f, 0.45f, 0.55f), default, default, default },
            new[] { Star(-0.42f, 0.26f, 0.65f, 0.8f), Star(0.28f, 0.26f, 0.45f, 0.55f), default, default },
            new Vector4[4],
            new[] { Star(0f, 0f, 0.38f, 0.4f), default, default, default },
            new Vector4[4],
            new Vector4[4]
        };

        private static readonly Vector4[] ReverseStars =
        {
            Vector4.zero,
            new Vector4(0f, 1f, 0f, 0f),
            Vector4.zero,
            new Vector4(1f, 0f, 0f, 0f),
            new Vector4(0f, 1f, 0f, 0f),
            Vector4.zero,
            Vector4.zero,
            Vector4.zero,
            Vector4.zero
        };

        [Tooltip("The camera to affect. Empty means every game camera.")]
        public Camera targetCamera;

        [Header("Ink")]
        [Tooltip("Brightness that counts as a mark.")]
        [Range(0f, 1f)] public float threshold = 0.5f;
        [Tooltip("Softness of that transition.")]
        [Range(0f, 1f)] public float softness = 0.05f;
        [Range(0f, 1f)] public float strokeLength = 0.65f;
        [Range(0f, 1f)] public float inkDensity = 0.65f;
        [Tooltip("Drops marks far from the hit, unless they are far brighter than white.")]
        [Range(0f, 1f)] public float backgroundSuppression = 0.9f;

        [Header("Stars")]
        [Range(0.25f, 2f)] public float starSize = 1f;
        [Range(0f, 1f)] public float starStrength = 1f;

        [Header("Subjects")]
        [Tooltip("Stay solid, and keep their silhouette. Materials are ignored, so alpha cutouts need Subject Mask.")]
        public Renderer[] subjects = Array.Empty<Renderer>();
        [Tooltip("R is visible subject coverage, for this camera and viewport. Wins over Subjects.")]
        public Texture subjectMask;

        public List<ImpactFrameStage> sequence = DefaultSequence();

        /// <summary>Viewport center of the hit, with a bottom-left origin.</summary>
        public Vector2 Center { get; private set; } = new Vector2(0.5f, 0.5f);

        /// <summary>Viewport attack direction, or zero for radial.</summary>
        public Vector2 Direction { get; private set; }

        public bool Active { get; private set; }

        public float Elapsed { get; private set; }

        /// <summary>Seconds in the whole sequence.</summary>
        public float Duration
        {
            get
            {
                float total = 0f;
                foreach (ImpactFrameStage stage in sequence)
                {
                    total += stage.durationMs;
                }
                return total / 1000f;
            }
        }

        /// <summary>The trigger a camera should draw, or null when there is nothing to show.</summary>
        public static ImpactFrameTrigger For(Camera camera)
        {
            foreach (ImpactFrameTrigger trigger in Enabled)
            {
                if ((trigger.targetCamera == null || trigger.targetCamera == camera) && trigger.TryGetStage(out ImpactFrameStage stage) && Strength(stage) > 0f)
                {
                    return trigger;
                }
            }
            return null;
        }

        public static float Strength(ImpactFrameStage stage)
        {
            return stage.mode == ImpactFrameMode.Original ? 0f : stage.intensity;
        }

        public static Vector4[] StarsOf(ImpactFramePose pose)
        {
            return Layouts[(int)pose];
        }

        public static Vector4 ReverseStarsOf(ImpactFramePose pose)
        {
            return ReverseStars[(int)pose];
        }

        /// <summary>The site's seven beats: silhouette, tear, burst, clean, release, detonate, shock.</summary>
        public static List<ImpactFrameStage> DefaultSequence()
        {
            return new List<ImpactFrameStage>
            {
                new ImpactFrameStage(ImpactFramePose.Silhouette, ImpactFrameMode.Inverted, 200f / 3f),
                new ImpactFrameStage(ImpactFramePose.Tear, ImpactFrameMode.Monochrome, 200f / 3f),
                new ImpactFrameStage(ImpactFramePose.Burst, ImpactFrameMode.Inverted, 200f / 3f),
                new ImpactFrameStage(ImpactFramePose.Clean, ImpactFrameMode.Monochrome, 100f / 3f),
                new ImpactFrameStage(ImpactFramePose.Release, ImpactFrameMode.Inverted, 100f / 3f),
                new ImpactFrameStage(ImpactFramePose.Detonate, ImpactFrameMode.Inverted, 200f / 3f),
                new ImpactFrameStage(ImpactFramePose.Shock, ImpactFrameMode.Monochrome, 200f / 3f)
            };
        }

        /// <summary>
        /// Starts the sequence at a viewport center, optionally with an attack direction. Returns false
        /// while one is running: triggers are ignored, not queued.
        /// </summary>
        public bool Fire(Vector2? center = null, Vector2? direction = null)
        {
            if (Active || sequence.Count == 0)
            {
                return false;
            }

            SetCenter(center ?? new Vector2(0.5f, 0.5f));
            SetDirection(direction);
            Elapsed = 0f;
            Active = true;
            return true;
        }

        /// <summary>Tracks a projected hit while the camera moves, without restarting.</summary>
        public void SetCenter(Vector2 center)
        {
            Center = new Vector2(Mathf.Clamp01(center.x), Mathf.Clamp01(center.y));
        }

        public void SetDirection(Vector2? direction)
        {
            Direction = direction.HasValue ? direction.Value.normalized : Vector2.zero;
        }

        /// <summary>Cancels now.</summary>
        public void Cancel()
        {
            Elapsed = 0f;
            Active = false;
        }

        public void Tick(float deltaTime)
        {
            if (!Active || !(deltaTime >= 0f) || float.IsInfinity(deltaTime))
            {
                return;
            }

            float duration = Duration;
            Elapsed = Mathf.Min(duration, Elapsed + deltaTime);
            if (Elapsed >= duration)
            {
                Active = false;
            }
        }

        /// <summary>The stage showing now. Short stages can be skipped by a long frame.</summary>
        public bool TryGetStage(out ImpactFrameStage stage)
        {
            stage = default;
            if (!Active)
            {
                return false;
            }

            float boundary = 0f;
            foreach (ImpactFrameStage entry in sequence)
            {
                boundary += entry.durationMs / 1000f;
                if (Elapsed < boundary)
                {
                    stage = entry;
                    return true;
                }
            }
            return false;
        }

        private static Vector4 Star(float x, float y, float size, float span)
        {
            return new Vector4(x, y, size, span / size);
        }

        private void OnEnable()
        {
            Enabled.Add(this);
        }

        private void OnDisable()
        {
            Enabled.Remove(this);
            Cancel();
        }

        private void Update()
        {
            if (Application.isPlaying)
            {
                Tick(Time.unscaledDeltaTime);
            }
        }
    }
}
