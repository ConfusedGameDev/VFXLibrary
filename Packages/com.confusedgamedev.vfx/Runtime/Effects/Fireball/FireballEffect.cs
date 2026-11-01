using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>
    /// Blazing Fireball. Flies along transform.forward. Keep calling Tick (Update does this in Play mode)
    /// until the effect finishes; collisions stay with the game, which calls Hit on contact.
    /// </summary>
    public sealed class FireballEffect : VfxEffect
    {
        private static readonly int ParticleCountId = Shader.PropertyToID("_ParticleCount");
        private static readonly int ImpactUpId = Shader.PropertyToID("_ImpactUp");
        private static readonly int ImpactId = Shader.PropertyToID("_Impact");

        [SerializeField] private Renderer impactRenderer;
        [SerializeField] private Renderer glowRenderer;

        private Vector3 impactUp = Vector3.up;
        private float travelSpeed;
        private bool impacted;

        /// <summary>Aims the fireball and sets its travel speed in units per second. 0 leaves movement to the game.</summary>
        public void SetDirection(Vector3 direction, float speed = 4f)
        {
            if (!IsPlaying || State == VfxState.Stopping || direction.sqrMagnitude <= 0f)
            {
                return;
            }

            transform.rotation = Quaternion.LookRotation(direction);
            travelSpeed = Mathf.Max(0f, speed);
        }

        /// <summary>
        /// Ends the fireball with its impact. Without a point it bursts at its leading surface; with one,
        /// the fireball moves so that surface sits on the contact. The normal defaults to facing back along flight.
        /// </summary>
        public void Hit(Vector3? worldPoint = null, Vector3? worldNormal = null)
        {
            if (State != VfxState.Playing)
            {
                return;
            }

            VfxPreset active = ActiveParameters;
            Vector3 contact = ContactPoint(EffectTime, active.size, StartProgress);

            if (worldPoint.HasValue)
            {
                transform.position = worldPoint.Value - transform.rotation * Vector3.Scale(contact, transform.lossyScale);
            }

            Vector3 normal = worldNormal ?? -transform.forward;
            if (normal.sqrMagnitude < 1e-10f)
            {
                normal = -transform.forward;
            }

            Transform impact = impactRenderer.transform;
            impact.localPosition = contact;
            impact.rotation = Quaternion.FromToRotation(Vector3.forward, normal.normalized);
            glowRenderer.transform.localPosition = contact;

            // Swapped to the source's axes, which the impact shader works in.
            Vector3 localUp = impact.InverseTransformDirection(Vector3.up);
            impactUp = new Vector3(localUp.z, localUp.y, localUp.x);

            impacted = true;
            Stop();
        }

        /// <summary>The fireball's leading surface in local space, including the start-up deformation.</summary>
        public static Vector3 ContactPoint(float time, float size, float startProgress)
        {
            // Source axes: +X is forward.
            float x = 0.65f + (0.46f + Mathf.Sin(time * 4.1f) * 0.035f) * size;
            float y = Mathf.Sin(5f + time * 3f) * 0.03f * size;
            float z = Mathf.Cos(7f + time * 2.7f) * 0.03f * size;

            if (startProgress < 1f)
            {
                float grow = startProgress * startProgress * (3f - 2f * startProgress);
                float curl = 1f - grow;
                y *= 0.22f + 0.78f * grow;
                z *= 0.22f + 0.78f * grow;
                x = (x * 0.38f - 0.16f) * (1f - grow) + x * grow;
                y += Mathf.Sin(x * 4.5f + startProgress * 7f) * curl * 0.15f;
            }

            return new Vector3(z, y, x);
        }

        protected override void OnPlay()
        {
            impacted = false;
            travelSpeed = 0f;
            impactUp = Vector3.up;
            SetImpactVisible(false, false);
        }

        protected override void OnTick(float deltaTime)
        {
            if (State == VfxState.Playing && travelSpeed > 0f)
            {
                transform.position += transform.forward * (deltaTime * travelSpeed);
            }

            bool ending = impacted && State == VfxState.Stopping;
            SetImpactVisible(ending, ending && EndProgress < 0.28f);
        }

        protected override void OnApplyParameters(MaterialPropertyBlock block, VfxPreset parameters)
        {
            int count = Mathf.Max(1, Mathf.RoundToInt(FireballMeshes.MaxParticles * parameters.density));

            // The impact borrows these ember slots while its puffs are on screen.
            if (impacted && State == VfxState.Stopping)
            {
                count = Mathf.Max(0, count - FireballMeshes.ImpactPuffs);
            }

            block.SetFloat(ParticleCountId, count);
            block.SetVector(ImpactUpId, impactUp);
            block.SetFloat(ImpactId, impacted ? 1f : 0f);
        }

        private void SetImpactVisible(bool impact, bool glow)
        {
            if (impactRenderer != null)
            {
                impactRenderer.enabled = impact;
            }

            if (glowRenderer != null)
            {
                glowRenderer.enabled = glow;
            }
        }
    }
}
