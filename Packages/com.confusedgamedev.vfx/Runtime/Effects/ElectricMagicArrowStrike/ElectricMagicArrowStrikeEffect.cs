using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Golden-Bladed Lightning Arrow. A golden arrow charges in a sigil and flies in lightning; contact bursts into a web and two shock rings.</summary>
    public sealed class ElectricMagicArrowStrikeEffect : VfxProjectileEffect
    {
        public const float TipReach = 1.7f;

        private static readonly int MotionId = Shader.PropertyToID("_Motion0");

        private ElectricArrowDischarge discharge;
        private MeshFilter arcFilter;
        private MeshFilter trailFilter;
        private MeshFilter impactFilter;
        private Mesh bakedArcs;
        private Mesh bakedTrails;
        private Mesh bakedImpact;
        private Transform sigil;
        private Renderer glow;
        private Vector3 sigilPosition;
        private Quaternion sigilRotation;
        private bool sigilLocked;
        private bool hasSeed;
        private uint nextSeed;
        private float syncedTime = -1f;

        protected override int MaxParticles => ElectricMagicArrowStrikeMeshes.MaxParticles;

        /// <summary>Plays with a chosen lightning seed, so a cast can be replayed exactly.</summary>
        public void Play(uint variationSeed)
        {
            nextSeed = variationSeed;
            hasSeed = true;
            Play();
        }

        protected override Vector3 CurrentContact(VfxPreset parameters)
        {
            return new Vector3(0f, 0f, TipReach * parameters.size);
        }

        protected override void OnPlay()
        {
            base.OnPlay();
            EnsureDischarge();
            uint seed = hasSeed ? nextSeed : unchecked((uint)Random.Range(int.MinValue, int.MaxValue));
            hasSeed = false;
            discharge.Restart(seed);
            sigilLocked = false;
            syncedTime = -1f;
        }

        protected override void OnTick(float deltaTime)
        {
            VfxPreset active = ActiveParameters;
            if (!sigilLocked && sigil != null && (State != VfxState.Playing || IsTraveling || EffectTime + deltaTime * active.speed >= active.startDuration))
            {
                // The sigil stays where the arrow left it.
                sigilPosition = sigil.position;
                sigilRotation = sigil.rotation;
                sigilLocked = true;
            }

            base.OnTick(deltaTime);
            if (glow != null)
            {
                glow.enabled = Impacted && State == VfxState.Stopping && EndProgress < 0.65f;
            }
        }

        protected override void OnApplyParameters(MaterialPropertyBlock block, VfxPreset parameters)
        {
            base.OnApplyParameters(block, parameters);
            bool ending = State == VfxState.Stopping || State == VfxState.Finished;
            float sinceEnd = EndProgress * parameters.stopDuration;
            float endTime = EffectTime - sinceEnd;
            block.SetVector(MotionId, new Vector4(IsTraveling ? 1f : 0f, ending ? endTime : -1f, sinceEnd, 0f));

            // Runs per renderer, so the lightning is only brought up to date once for each time.
            if (discharge != null && syncedTime != EffectTime)
            {
                syncedTime = EffectTime;
                discharge.SyncArrow(ending ? endTime : EffectTime, IsTraveling);
                if (Impacted)
                {
                    discharge.SyncImpact(sinceEnd);
                }

                if (sigil != null)
                {
                    if (sigilLocked)
                    {
                        sigil.SetPositionAndRotation(sigilPosition, sigilRotation);
                    }
                    else
                    {
                        sigil.localPosition = new Vector3(0f, 0f, -TipReach * parameters.size);
                        sigil.localRotation = Quaternion.identity;
                    }
                }
            }
        }

        private void OnDisable()
        {
            // An edit-mode preview must not leave its temporary meshes on the object.
            if (Application.isPlaying || discharge == null)
            {
                return;
            }

            Swap(arcFilter, bakedArcs);
            Swap(trailFilter, bakedTrails);
            Swap(impactFilter, bakedImpact);
            discharge.Release();
            discharge = null;
        }

        protected override void OnDestroy()
        {
            base.OnDestroy();
            discharge?.Release();
            discharge = null;
        }

        private void EnsureDischarge()
        {
            if (discharge != null)
            {
                return;
            }

            discharge = new ElectricArrowDischarge(0u);
            arcFilter = Layer("Arcs");
            trailFilter = Layer("Trails");
            impactFilter = Layer("Impact");
            bakedArcs = Swap(arcFilter, discharge.Arcs.Mesh);
            bakedTrails = Swap(trailFilter, discharge.Trails.Mesh);
            bakedImpact = Swap(impactFilter, discharge.Blast.Mesh);
            sigil = transform.Find("Sigil");
            Transform contact = transform.Find("Glow");
            glow = contact != null ? contact.GetComponent<Renderer>() : null;
        }

        private MeshFilter Layer(string layer)
        {
            Transform child = transform.Find(layer);
            return child != null ? child.GetComponent<MeshFilter>() : null;
        }

        private static Mesh Swap(MeshFilter filter, Mesh mesh)
        {
            if (filter == null)
            {
                return null;
            }

            Mesh previous = filter.sharedMesh;
            filter.sharedMesh = mesh;
            return previous;
        }
    }
}
