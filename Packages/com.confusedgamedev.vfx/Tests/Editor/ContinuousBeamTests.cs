using NUnit.Framework;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Tests
{
    public class ContinuousBeamTests
    {
        [Test]
        public void Preset_MatchesSiteDefaults()
        {
            var preset = ScriptableObject.CreateInstance<ContinuousBeamPreset>();

            Assert.That(ColorUtility.ToHtmlStringRGB(preset.color), Is.EqualTo("FF6555"));
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
            var effect = root.AddComponent<ContinuousBeamEffect>();

            Assert.That(effect.LayerCounts(0.5f), Is.EqualTo(new Vector2Int(256, 0)));

            Object.DestroyImmediate(root);
        }

        [Test]
        public void Length_ScalesOnlyAlongTheBeam()
        {
            var root = new GameObject("Beam");
            var effect = root.AddComponent<ContinuousBeamEffect>();

            effect.SetEndpoints(new Vector3(0f, 0f, 1f), new Vector3(0f, 9.6f, 1f));

            Assert.That(root.transform.position, Is.EqualTo(new Vector3(0f, 4.8f, 1f)));
            Assert.That(root.transform.forward.y, Is.EqualTo(1f).Within(0.001f));
            Assert.That(root.transform.localScale.z, Is.EqualTo(2f).Within(0.001f));
            Assert.That(root.transform.localScale.y, Is.EqualTo(1f));

            Object.DestroyImmediate(root);
        }

        [Test]
        public void Tube_SpansBothEndPoints()
        {
            Mesh mesh = ContinuousBeamMeshes.CreateBody();

            Assert.That(mesh.vertexCount, Is.EqualTo(49 * 13));
            Assert.That(mesh.vertices[0].x, Is.EqualTo(-2.4f).Within(0.001f));
            Assert.That(mesh.vertices[mesh.vertexCount - 1].x, Is.EqualTo(2.4f).Within(0.001f));

            Object.DestroyImmediate(mesh);
        }
    }
}
