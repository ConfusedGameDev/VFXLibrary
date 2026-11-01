using NUnit.Framework;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Tests
{
    public class VfxEffectTests
    {
        private sealed class TestPreset : VfxPreset
        {
        }

        private sealed class TestEffect : VfxEffect
        {
        }

        private GameObject gameObject;
        private TestEffect effect;
        private TestPreset preset;
        private int finishedCount;

        [SetUp]
        public void SetUp()
        {
            preset = ScriptableObject.CreateInstance<TestPreset>();
            preset.duration = 1f;
            preset.stopDuration = 0.5f;

            gameObject = new GameObject("Effect");
            effect = gameObject.AddComponent<TestEffect>();
            effect.SetPreset(preset);

            finishedCount = 0;
            effect.onFinished.AddListener(() => finishedCount++);
        }

        [TearDown]
        public void TearDown()
        {
            Object.DestroyImmediate(gameObject);
            Object.DestroyImmediate(preset);
        }

        [Test]
        public void OneShot_FinishesAtDuration()
        {
            effect.Play();

            effect.Tick(0.9f);
            Assert.That(effect.State, Is.EqualTo(VfxState.Playing));

            effect.Tick(0.2f);
            Assert.That(effect.State, Is.EqualTo(VfxState.Finished));
            Assert.That(finishedCount, Is.EqualTo(1));
        }

        [Test]
        public void Speed_ScalesEffectTime()
        {
            preset.speed = 2f;
            effect.Play();

            effect.Tick(0.25f);

            Assert.That(effect.EffectTime, Is.EqualTo(0.5f).Within(0.0001f));
        }

        [Test]
        public void Looping_RunsPastDurationUntilStopped()
        {
            preset.playback = VfxPlayback.Looping;
            effect.Play();

            effect.Tick(10f);

            Assert.That(effect.State, Is.EqualTo(VfxState.Playing));
        }

        [Test]
        public void Stop_FadesThenFinishes()
        {
            preset.playback = VfxPlayback.Looping;
            effect.Play();

            effect.Stop();
            effect.Tick(0.25f);

            Assert.That(effect.State, Is.EqualTo(VfxState.Stopping));
            Assert.That(effect.Fade, Is.EqualTo(0.5f).Within(0.0001f));

            effect.Tick(0.3f);

            Assert.That(effect.State, Is.EqualTo(VfxState.Finished));
            Assert.That(finishedCount, Is.EqualTo(1));
        }

        [Test]
        public void StopImmediate_FinishesAtOnce()
        {
            effect.Play();

            effect.Stop(immediate: true);

            Assert.That(effect.State, Is.EqualTo(VfxState.Finished));
            Assert.That(finishedCount, Is.EqualTo(1));
        }

        [Test]
        public void Stop_WhenNotPlaying_DoesNothing()
        {
            effect.Stop();

            Assert.That(effect.State, Is.EqualTo(VfxState.Idle));
            Assert.That(finishedCount, Is.EqualTo(0));
        }

        [Test]
        public void Replay_RestartsClockAtZero()
        {
            effect.Play();
            effect.Tick(0.5f);

            effect.Play();

            Assert.That(effect.EffectTime, Is.EqualTo(0f));
            Assert.That(effect.Fade, Is.EqualTo(1f));
        }

        [Test]
        public void RuntimeParameters_LeaveSharedPresetUntouched()
        {
            effect.RuntimeParameters.size = 2f;

            Assert.That(preset.size, Is.EqualTo(1f));
            Assert.That(effect.RuntimeParameters, Is.Not.SameAs(preset));
        }

        [Test]
        public void RuntimeParameters_DriveTheClock()
        {
            effect.RuntimeParameters.speed = 2f;
            effect.Play();

            effect.Tick(0.25f);

            Assert.That(effect.EffectTime, Is.EqualTo(0.5f).Within(0.0001f));
        }

        [Test]
        public void SetPreset_DiscardsRuntimeChanges()
        {
            effect.RuntimeParameters.size = 2f;

            effect.SetPreset(preset);

            Assert.That(effect.RuntimeParameters.size, Is.EqualTo(1f));
        }

        [Test]
        public void EndAction_DoesNotDestroyInEditMode()
        {
            preset.endAction = VfxEndAction.Destroy;
            effect.Play();

            effect.Stop(immediate: true);

            Assert.That(effect != null, Is.True);
            Assert.That(gameObject.activeSelf, Is.True);
        }

        [Test]
        public void Pool_RecyclesInstances()
        {
            var pool = new VfxPool(effect, prewarmCount: 2);
            Assert.That(pool.AvailableCount, Is.EqualTo(2));

            VfxEffect spawned = pool.Spawn(Vector3.one, Quaternion.identity);
            Assert.That(pool.AvailableCount, Is.EqualTo(1));
            Assert.That(spawned.gameObject.activeSelf, Is.True);
            Assert.That(spawned.IsPlaying, Is.True);
            Assert.That(spawned.transform.position, Is.EqualTo(Vector3.one));

            pool.Release(spawned);
            Assert.That(pool.AvailableCount, Is.EqualTo(2));
            Assert.That(pool.Spawn(Vector3.zero, Quaternion.identity), Is.SameAs(spawned));

            foreach (TestEffect instance in Resources.FindObjectsOfTypeAll<TestEffect>())
            {
                if (instance != effect)
                {
                    Object.DestroyImmediate(instance.gameObject);
                }
            }
        }
    }
}
