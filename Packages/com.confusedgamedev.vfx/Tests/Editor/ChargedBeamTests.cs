using NUnit.Framework;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Tests
{
    public class ChargedBeamTests
    {
        [Test]
        public void Preset_MatchesSiteDefaults()
        {
            var preset = ScriptableObject.CreateInstance<ChargedBeamPreset>();

            Assert.That(ColorUtility.ToHtmlStringRGB(preset.color), Is.EqualTo("F6C76C"));
            Assert.That(preset.density, Is.EqualTo(0.5f));
            Assert.That(preset.startDuration, Is.EqualTo(1.6f));
            Assert.That(preset.stopDuration, Is.EqualTo(0.6f));
            Assert.That(preset.playback, Is.EqualTo(VfxPlayback.Looping));

            Object.DestroyImmediate(preset);
        }

        [Test]
        public void LayerCounts_SplitThePool()
        {
            var root = new GameObject("Beam");
            var effect = root.AddComponent<ChargedBeamEffect>();

            Assert.That(effect.LayerCounts(0.5f), Is.EqualTo(new Vector2Int(378, 6)));

            Object.DestroyImmediate(root);
        }

        [Test]
        public void Lance_HasFiveStrips()
        {
            Mesh mesh = ChargedBeamMeshes.CreateLance();

            Assert.That(mesh.vertexCount, Is.EqualTo(5 * 65 * 2));

            Object.DestroyImmediate(mesh);
        }
    }
}
