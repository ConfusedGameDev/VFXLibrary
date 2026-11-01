using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Billowing Airburst. A fireball bursts in the air, throwing jets of smoke as its flame cools to soot.</summary>
    public sealed class BillowingAirburstEffect : VfxBurstEffect
    {
        private static readonly int MotionId = Shader.PropertyToID("_Motion0");
        private static readonly int PathsId = Shader.PropertyToID("_JetPaths");
        private static readonly int BendsId = Shader.PropertyToID("_JetBends");

        private readonly Vector4[] paths = new Vector4[BillowingAirburstMeshes.Jets];
        private readonly Vector4[] bends = new Vector4[BillowingAirburstMeshes.Jets];
        private Vector4 offset;
        private bool hasCast;
        private bool hasSeed;
        private uint nextSeed;

        /// <summary>Plays with a chosen seed, so a cast can be replayed exactly.</summary>
        public void Play(uint variationSeed)
        {
            nextSeed = variationSeed;
            hasSeed = true;
            Play();
        }

        protected override Vector4 LayerCounts(float density)
        {
            return BillowingAirburstMeshes.LayerCounts(density);
        }

        protected override void OnPlay()
        {
            base.OnPlay();
            Roll(hasSeed ? nextSeed : unchecked((uint)Random.Range(int.MinValue, int.MaxValue)));
            hasSeed = false;
        }

        protected override void OnApplyParameters(MaterialPropertyBlock block, VfxPreset parameters)
        {
            base.OnApplyParameters(block, parameters);
            if (!hasCast)
            {
                Roll(0u);
            }

            block.SetVector(MotionId, offset);
            block.SetVectorArray(PathsId, paths);
            block.SetVectorArray(BendsId, bends);
        }

        private void Roll(uint seed)
        {
            offset = BillowingAirburstMeshes.RollCast(seed, paths, bends);
            hasCast = true;
        }
    }
}
