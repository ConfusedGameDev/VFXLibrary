using NUnit.Framework;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Tests
{
    public class ImpactFrameTests
    {
        private GameObject host;
        private ImpactFrameTrigger trigger;

        [SetUp]
        public void SetUp()
        {
            host = new GameObject("ImpactFrame");
            trigger = host.AddComponent<ImpactFrameTrigger>();
        }

        [TearDown]
        public void TearDown()
        {
            Object.DestroyImmediate(host);
        }

        [Test]
        public void Sequence_MatchesSiteDefaults()
        {
            Assert.That(trigger.sequence.Count, Is.EqualTo(7));
            Assert.That(trigger.Duration, Is.EqualTo(0.4f).Within(1e-5f));
            Assert.That(trigger.threshold, Is.EqualTo(0.5f));
            Assert.That(trigger.strokeLength, Is.EqualTo(0.65f));
        }

        [Test]
        public void Fire_IsIgnoredWhileActive()
        {
            Assert.That(trigger.Fire(), Is.True);
            Assert.That(trigger.Fire(), Is.False);
            trigger.Tick(1f);
            Assert.That(trigger.Active, Is.False);
            Assert.That(trigger.Fire(), Is.True);
        }

        [Test]
        public void Tick_WalksTheBeats()
        {
            trigger.Fire(new Vector2(0.25f, 2f));
            Assert.That(trigger.Center, Is.EqualTo(new Vector2(0.25f, 1f)));

            trigger.Tick(0.1f);
            trigger.TryGetStage(out ImpactFrameStage stage);
            Assert.That(stage.pose, Is.EqualTo(ImpactFramePose.Tear));

            trigger.Tick(0.25f);
            trigger.TryGetStage(out stage);
            Assert.That(stage.pose, Is.EqualTo(ImpactFramePose.Shock));
        }

        [Test]
        public void For_ReturnsOnlyAVisibleTrigger()
        {
            Assert.That(ImpactFrameTrigger.For(null), Is.Null);
            trigger.Fire();
            Assert.That(ImpactFrameTrigger.For(null), Is.EqualTo(trigger));

            trigger.sequence[0] = new ImpactFrameStage(ImpactFramePose.Silhouette, ImpactFrameMode.Original, 66f);
            Assert.That(ImpactFrameTrigger.For(null), Is.Null);
        }
    }
}
