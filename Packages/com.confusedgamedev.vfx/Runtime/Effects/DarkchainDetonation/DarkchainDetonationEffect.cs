using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Darkchain Sigil Rupture. Twin sigils chain up, feed a black orb, then it collapses and detonates. Needs the camera's Opaque Texture.</summary>
    public sealed class DarkchainDetonationEffect : VfxBurstEffect
    {
        private static readonly int Motion0Id = Shader.PropertyToID("_Motion0");
        private static readonly int Motion1Id = Shader.PropertyToID("_Motion1");
        private static readonly int Motion2Id = Shader.PropertyToID("_Motion2");

        private Vector4 motion0;
        private Vector4 motion1;
        private Vector4 motion2;
        private float motionTime = -1f;

        protected override Vector4 LayerCounts(float density)
        {
            return DarkchainDetonationMeshes.LayerCounts(density);
        }

        protected override void OnApplyParameters(MaterialPropertyBlock block, VfxPreset parameters)
        {
            base.OnApplyParameters(block, parameters);

            // Runs per renderer, so the motion is only worked out once for each time.
            if (motionTime != EffectTime)
            {
                motionTime = EffectTime;
                DarkchainMotion motion = DarkchainMotion.At(EffectTime);
                motion0 = new Vector4(motion.jetTravel, motion.jetFade, motion.warpKick, motion.warpFade);
                motion1 = new Vector4(motion.tension, motion.flow, motion.radius, motion.beat);
                motion2 = new Vector4(motion.orbAlive, motion.blastRadius, motion.waveRadius, 0f);
            }

            block.SetVector(Motion0Id, motion0);
            block.SetVector(Motion1Id, motion1);
            block.SetVector(Motion2Id, motion2);
        }
    }
}
