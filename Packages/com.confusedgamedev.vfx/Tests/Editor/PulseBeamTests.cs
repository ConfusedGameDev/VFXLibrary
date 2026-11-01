using NUnit.Framework;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Tests
{
    public class PulseBeamTests
    {
        [Test]
        public void Preset_MatchesSiteDefaults()
        {
            var preset = ScriptableObject.CreateInstance<PulseBeamPreset>();

            Assert.That(ColorUtility.ToHtmlStringRGB(preset.color), Is.EqualTo("71E7DC"));
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
            var effect = root.AddComponent<PulseBeamEffect>();

            Assert.That(effect.LayerCounts(0.5f), Is.EqualTo(new Vector2Int(250, 6)));

            Object.DestroyImmediate(root);
        }

        [Test]
        public void Rings_FaceAlongTheBeam()
        {
            Mesh mesh = PulseBeamMeshes.CreateRings();

            Assert.That(mesh.vertexCount, Is.EqualTo(PulseBeamMeshes.MaxRings * 33 * 6));
            foreach (Vector3 vertex in mesh.vertices)
            {
                Assert.That(Mathf.Abs(vertex.x), Is.LessThanOrEqualTo(0.0121f));
            }

            Object.DestroyImmediate(mesh);
        }
    }
}
