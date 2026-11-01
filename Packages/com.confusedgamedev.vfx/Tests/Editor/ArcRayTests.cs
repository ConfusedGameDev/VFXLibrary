using NUnit.Framework;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Tests
{
    public class ArcRayTests
    {
        [Test]
        public void Preset_MatchesSiteDefaults()
        {
            var preset = ScriptableObject.CreateInstance<ArcRayPreset>();

            Assert.That(ColorUtility.ToHtmlStringRGB(preset.color), Is.EqualTo("2878FF"));
            Assert.That(preset.density, Is.EqualTo(0.5f));
            Assert.That(preset.startDuration, Is.EqualTo(0.4f));
            Assert.That(preset.stopDuration, Is.EqualTo(0.6f));
            Assert.That(preset.playback, Is.EqualTo(VfxPlayback.Looping));

            Object.DestroyImmediate(preset);
        }

        [Test]
        public void LayerCounts_SplitThePool()
        {
            var root = new GameObject("Beam");
            var effect = root.AddComponent<ArcRayEffect>();

            Assert.That(effect.LayerCounts(0.5f), Is.EqualTo(new Vector2Int(384, 0)));

            Object.DestroyImmediate(root);
        }

        [Test]
        public void Lightning_HasEveryArcAndFork()
        {
            Mesh mesh = ArcRayMeshes.CreateLightning();

            Assert.That(mesh.vertexCount, Is.EqualTo(12 * (97 + 3 * 25) * 2));

            Object.DestroyImmediate(mesh);
        }
    }
}
