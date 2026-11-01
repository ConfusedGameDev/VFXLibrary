using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Runic Crystal Missiles. Up to six gems orbit the flight axis, each with its spiral rune trail.</summary>
    public sealed class ArcaneMissileEffect : VfxProjectileEffect
    {
        private static readonly int QuantityId = Shader.PropertyToID("_Quantity");
        private static readonly int SpreadId = Shader.PropertyToID("_Spread");

        protected override int MaxParticles => ArcaneMissileMeshes.MaxParticles;

        protected override Vector3 CurrentContact(VfxPreset parameters)
        {
            var missile = (ArcaneMissilePreset)parameters;
            return ContactPoint(EffectTime, missile.size, missile.quantity, missile.spread, StartProgress);
        }

        /// <summary>The foremost gem tip in local space, including the side tips during assembly.</summary>
        public static Vector3 ContactPoint(float time, float size, int quantity, float spread, float startProgress)
        {
            float grow = startProgress * startProgress * (3f - 2f * startProgress);
            float curl = 1f - grow;
            float step = quantity == 3 ? 2.094395f : Mathf.PI * 2f / quantity;
            float best = float.NegativeInfinity;
            Vector3 contact = Vector3.zero;

            for (int i = 0; i < quantity; i++)
            {
                float a = i * step - time * 3f;
                float cx = 0.85f + Mathf.Sin(a * 2f) * 0.09f * size;
                float cy = Mathf.Cos(a) * 0.26f * size * spread;
                float cz = Mathf.Sin(a) * 0.26f * size * spread;

                for (int tip = 0; tip < 6; tip++)
                {
                    int axis = tip / 2;
                    float sign = tip % 2 == 1 ? -1f : 1f;
                    float x = cx + (axis == 0 ? sign * 0.182f * size : 0f);
                    float y = cy + (axis == 1 ? sign * 0.078f * size : 0f);
                    float z = cz + (axis == 2 ? sign * 0.078f * size : 0f);
                    y *= 1f + curl * 0.8f;
                    z *= 1f + curl * 0.8f;
                    x += Mathf.Sin(y * 7f) * curl * 0.4f;

                    if (x > best)
                    {
                        best = x;
                        contact = new Vector3(z, y, x);
                    }
                }
            }

            return contact;
        }

        protected override void OnApplyParameters(MaterialPropertyBlock block, VfxPreset parameters)
        {
            base.OnApplyParameters(block, parameters);

            var missile = (ArcaneMissilePreset)parameters;
            block.SetFloat(QuantityId, missile.quantity);
            block.SetFloat(SpreadId, missile.spread);
        }
    }
}
