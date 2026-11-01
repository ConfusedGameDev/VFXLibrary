using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>
    /// Base for beams. A beam is centred on the transform and lies along transform.forward. Its length
    /// is the root's Z scale, the source's group scale, so both end points stay fixed while it animates.
    /// </summary>
    public abstract class VfxBeamEffect : VfxEffect
    {
        /// <summary>The length the meshes are built at.</summary>
        public const float BaseLength = 4.8f;

        private const float MinimumLength = 0.001f;

        private static readonly int ParticleCountId = Shader.PropertyToID("_ParticleCount");
        private static readonly int LayerCountsId = Shader.PropertyToID("_LayerCounts");
        private static readonly int StretchId = Shader.PropertyToID("_Stretch");
        private static readonly int EmitterTimeId = Shader.PropertyToID("_EmitterTime");

        [SerializeField, Min(MinimumLength)] private float length = BaseLength;

        /// <summary>Distance between the end points, in units of the root's own scale.</summary>
        public float Length
        {
            get => length;
            set
            {
                length = Mathf.Max(MinimumLength, value);
                ApplyLength();
                ApplyParameters();
            }
        }

        protected abstract int MaxParticles { get; }

        /// <summary>Capacity of a second instanced layer, which takes its count from the same pool.</summary>
        protected virtual int SecondaryMaximum => 0;

        protected virtual float SecondaryWeight => 0f;

        /// <summary>Places the beam between two world positions.</summary>
        public void SetEndpoints(Vector3 start, Vector3 end)
        {
            Vector3 span = end - start;
            transform.position = (start + end) * 0.5f;
            if (span.sqrMagnitude > 0f)
            {
                transform.rotation = Quaternion.LookRotation(span);
            }

            Length = span.magnitude / transform.lossyScale.y;
        }

        /// <summary>Instances of the particle and second layers at a density, as the source splits its pool.</summary>
        public Vector2Int LayerCounts(float density)
        {
            int desired = Mathf.Max(1, RoundHalfUp(MaxParticles * density));
            int secondary = Mathf.Min(SecondaryMaximum, RoundHalfUp(desired * SecondaryWeight));
            return new Vector2Int(desired - secondary, secondary);
        }

        protected override void OnEnable()
        {
            ApplyLength();
            base.OnEnable();
        }

        protected override void Update()
        {
            ApplyLength();
            base.Update();
        }

        protected override void OnApplyParameters(MaterialPropertyBlock block, VfxPreset parameters)
        {
            Vector2Int counts = LayerCounts(parameters.density);
            block.SetFloat(ParticleCountId, counts.x);
            block.SetVector(LayerCountsId, new Vector4(counts.y, 0f, 0f, 0f));
            block.SetFloat(StretchId, length / BaseLength);
            block.SetFloat(EmitterTimeId, EffectTime - EndProgress * parameters.stopDuration);
        }

        private void ApplyLength()
        {
            Vector3 scale = transform.localScale;
            float z = scale.y * length / BaseLength;
            if (!Mathf.Approximately(scale.z, z))
            {
                scale.z = z;
                transform.localScale = scale;
            }
        }

        private static int RoundHalfUp(float value)
        {
            return Mathf.FloorToInt(value + 0.5f);
        }
    }
}
