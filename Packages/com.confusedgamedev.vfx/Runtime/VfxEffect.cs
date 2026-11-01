using UnityEngine;
using UnityEngine.Events;

namespace ConfusedGameDev.Vfx
{
    public enum VfxState
    {
        Idle,
        Playing,
        Stopping,
        Finished
    }

    /// <summary>
    /// Base component for every effect. Owns the clock and lifecycle, so replays restart at 0 and the
    /// same code path runs in Play mode and in the editor preview. Subclasses only push parameters.
    /// </summary>
    [ExecuteAlways]
    [DisallowMultipleComponent]
    public abstract class VfxEffect : MonoBehaviour
    {
        protected static readonly int EffectTimeId = Shader.PropertyToID("_EffectTime");
        protected static readonly int EffectFadeId = Shader.PropertyToID("_EffectFade");
        protected static readonly int EffectColorId = Shader.PropertyToID("_EffectColor");
        protected static readonly int EffectSizeId = Shader.PropertyToID("_EffectSize");
        protected static readonly int EffectDetailId = Shader.PropertyToID("_EffectDetail");
        protected static readonly int LifeStageId = Shader.PropertyToID("_LifeStage");
        protected static readonly int LifeStartId = Shader.PropertyToID("_LifeStart");
        protected static readonly int LifeEndId = Shader.PropertyToID("_LifeEnd");

        [SerializeField] private VfxPreset preset;
        [SerializeField] private bool playOnEnable = true;
        [SerializeField] private Renderer[] renderers = System.Array.Empty<Renderer>();

        public UnityEvent onFinished = new UnityEvent();

        private MaterialPropertyBlock propertyBlock;
        private VfxPreset runtimeParameters;
        private float stopElapsed;

        internal VfxPool ownerPool;

        public VfxState State { get; private set; } = VfxState.Idle;

        /// <summary>Seconds of effect time since Play(), already scaled by the preset's speed.</summary>
        public float EffectTime { get; private set; }

        /// <summary>1 while playing, falling to 0 across the stop fade.</summary>
        public float Fade { get; private set; } = 1f;

        /// <summary>0 to 1 across the start-up animation. Holds its value once Stop() is called.</summary>
        public float StartProgress { get; private set; }

        /// <summary>0 to 1 across the ending.</summary>
        public float EndProgress => 1f - Fade;

        public bool IsPlaying => State == VfxState.Playing || State == VfxState.Stopping;

        /// <summary>The shared preset asset. Assigning goes through SetPreset.</summary>
        public VfxPreset Preset => preset;

        /// <summary>
        /// A private copy of the preset for this instance. The first access clones the asset, so code can
        /// animate values such as a charge-up without touching it. Call ApplyParameters after changing it.
        /// </summary>
        public VfxPreset RuntimeParameters
        {
            get
            {
                if (runtimeParameters == null && preset != null)
                {
                    runtimeParameters = Instantiate(preset);
                    runtimeParameters.hideFlags = HideFlags.HideAndDontSave;
                }
                return runtimeParameters;
            }
        }

        /// <summary>The values this instance renders with right now.</summary>
        protected VfxPreset ActiveParameters => runtimeParameters != null ? runtimeParameters : preset;

        public void Play()
        {
            EffectTime = 0f;
            stopElapsed = 0f;
            Fade = 1f;
            State = VfxState.Playing;
            UpdateStartProgress();
            OnPlay();
            ApplyParameters();
        }

        /// <summary>Fades out over the preset's stop duration, or ends now when immediate is true.</summary>
        public void Stop(bool immediate = false)
        {
            if (!IsPlaying)
            {
                return;
            }

            VfxPreset active = ActiveParameters;
            if (immediate || active == null || active.stopDuration <= 0f)
            {
                Finish();
                return;
            }

            stopElapsed = 0f;
            State = VfxState.Stopping;
        }

        /// <summary>Swaps the preset and drops any runtime changes made to the previous one.</summary>
        public void SetPreset(VfxPreset newPreset)
        {
            preset = newPreset;
            ReleaseRuntimeParameters();
            ApplyParameters();
        }

        /// <summary>Advances the effect. Update calls this in Play mode, the editor preview calls it otherwise.</summary>
        public void Tick(float deltaTime)
        {
            VfxPreset active = ActiveParameters;
            if (!IsPlaying || active == null)
            {
                return;
            }

            OnTick(deltaTime);

            // Lifecycle runs on effect time, so speed scales the ending as it does on the site.
            float effectDelta = deltaTime * active.speed;
            EffectTime += effectDelta;

            if (State == VfxState.Stopping)
            {
                stopElapsed += effectDelta;
                Fade = Mathf.Clamp01(1f - stopElapsed / active.stopDuration);
                if (stopElapsed >= active.stopDuration)
                {
                    Finish();
                    return;
                }
            }
            else
            {
                if (active.playback == VfxPlayback.OneShot && EffectTime >= active.duration)
                {
                    Finish();
                    return;
                }

                UpdateStartProgress();
            }

            ApplyParameters();
        }

        /// <summary>Pushes the current values to every renderer.</summary>
        public void ApplyParameters()
        {
            VfxPreset active = ActiveParameters;
            if (active == null)
            {
                return;
            }

            propertyBlock ??= new MaterialPropertyBlock();

            foreach (Renderer target in renderers)
            {
                if (target == null)
                {
                    continue;
                }

                // Blocks keep instances independent without creating material assets in edit mode.
                target.GetPropertyBlock(propertyBlock);
                propertyBlock.SetFloat(EffectTimeId, EffectTime);
                propertyBlock.SetFloat(EffectFadeId, Fade);
                propertyBlock.SetColor(EffectColorId, active.color); // SetColor converts to linear itself.
                propertyBlock.SetFloat(EffectSizeId, active.size);
                propertyBlock.SetFloat(EffectDetailId, active.detail);
                propertyBlock.SetFloat(LifeStartId, StartProgress);
                propertyBlock.SetFloat(LifeEndId, EndProgress);
                propertyBlock.SetFloat(LifeStageId, CurrentLifeStage());
                OnApplyParameters(propertyBlock, active);
                target.SetPropertyBlock(propertyBlock);
            }
        }

        /// <summary>Called when an edit-mode preview ends or the scene saves. Undo temporary scene changes here.</summary>
        public virtual void EndEditPreview()
        {
        }

        /// <summary>Called on Play(), after the clock resets. Restart particles and spawn state here.</summary>
        protected virtual void OnPlay()
        {
        }

        /// <summary>Called every Tick with unscaled seconds, before the clock advances.</summary>
        protected virtual void OnTick(float deltaTime)
        {
        }

        /// <summary>Called per renderer to set effect-specific shader properties.</summary>
        protected virtual void OnApplyParameters(MaterialPropertyBlock block, VfxPreset parameters)
        {
        }

        protected virtual void OnEnable()
        {
            if (Application.isPlaying && playOnEnable)
            {
                Play();
            }
            else
            {
                ApplyParameters();
            }
        }

        protected virtual void Update()
        {
            if (Application.isPlaying)
            {
                Tick(Time.deltaTime);
            }
        }

        protected virtual void OnDestroy()
        {
            ReleaseRuntimeParameters();
        }

        private void UpdateStartProgress()
        {
            VfxPreset active = ActiveParameters;
            StartProgress = active == null || active.startDuration <= 0f
                ? 1f
                : Mathf.Min(1f, EffectTime / active.startDuration);
        }

        // 0 starting, 1 steady, 2 ending. Shaders skip their lifecycle work on 1.
        private float CurrentLifeStage()
        {
            if (State == VfxState.Stopping || State == VfxState.Finished)
            {
                return 2f;
            }
            return StartProgress < 1f ? 0f : 1f;
        }

        private void Finish()
        {
            Fade = 0f;
            State = VfxState.Finished;
            ApplyParameters();
            onFinished.Invoke();

            // Ending an edit-mode preview must never remove the object from the scene.
            if (!Application.isPlaying)
            {
                return;
            }

            VfxPreset active = ActiveParameters;
            switch (active != null ? active.endAction : VfxEndAction.None)
            {
                case VfxEndAction.Disable:
                    gameObject.SetActive(false);
                    break;
                case VfxEndAction.Destroy:
                    Destroy(gameObject);
                    break;
                case VfxEndAction.ReturnToPool:
                    if (ownerPool != null)
                    {
                        ownerPool.Release(this);
                    }
                    else
                    {
                        gameObject.SetActive(false);
                    }
                    break;
            }
        }

        private void ReleaseRuntimeParameters()
        {
            if (runtimeParameters == null)
            {
                return;
            }

            if (Application.isPlaying)
            {
                Destroy(runtimeParameters);
            }
            else
            {
                DestroyImmediate(runtimeParameters);
            }
            runtimeParameters = null;
        }

#if UNITY_EDITOR
        private void OnValidate()
        {
            ApplyParameters();
        }
#endif
    }
}
