using NUnit.Framework;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Tests
{
    public class SpellIndicatorCircleTests
    {
        private GameObject host;
        private SpellIndicatorCirclePreset preset;
        private SpellIndicatorCircleEffect effect;

        [SetUp]
        public void SetUp()
        {
            host = new GameObject("SpellIndicatorCircle");
            preset = ScriptableObject.CreateInstance<SpellIndicatorCirclePreset>();
            effect = host.AddComponent<SpellIndicatorCircleEffect>();
            effect.SetPreset(preset);
        }

        [TearDown]
        public void TearDown()
        {
            Object.DestroyImmediate(host);
            Object.DestroyImmediate(preset);
        }

        [Test]
        public void Preset_MatchesSiteDefaults()
        {
            Assert.That(ColorUtility.ToHtmlStringRGB(preset.color), Is.EqualTo("FF303E"));
            Assert.That(preset.radius, Is.EqualTo(3f));
            Assert.That(preset.warningDuration, Is.EqualTo(2f));
            Assert.That(preset.AngleDegrees, Is.EqualTo(360f));
        }

        [Test]
        public void Surface_IsOneQuad()
        {
            Mesh mesh = SpellIndicatorCircleMeshes.CreateSurface();

            Assert.That(mesh.vertexCount, Is.EqualTo(4));
            Object.DestroyImmediate(mesh);
        }

        [Test]
        public void Auto_FillsThenFlashesThenFinishes()
        {
            effect.Play();
            effect.Tick(1f);
            Assert.That(effect.Progress, Is.EqualTo(0.5f));

            effect.Tick(1.1f);
            Assert.That(effect.Progress, Is.EqualTo(1f));
            Assert.That(effect.State, Is.EqualTo(VfxState.Playing));

            effect.Tick(0.1f);
            Assert.That(effect.State, Is.EqualTo(VfxState.Finished));
        }

        [Test]
        public void Manual_FollowsSetProgressOnly()
        {
            preset.progressMode = VfxIndicatorProgress.Manual;
            effect.Play();
            effect.Tick(5f);
            Assert.That(effect.Progress, Is.EqualTo(0f));

            effect.SetProgress(0.25f);
            Assert.That(effect.Progress, Is.EqualTo(0.25f));
        }

        [Test]
        public void SetProgress_IsIgnoredInAuto()
        {
            effect.Play();
            effect.SetProgress(0.5f);

            Assert.That(effect.Progress, Is.EqualTo(0f));
        }
    }
}
