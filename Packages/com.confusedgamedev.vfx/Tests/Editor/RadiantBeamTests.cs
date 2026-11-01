using NUnit.Framework;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Tests
{
    public class RadiantBeamTests
    {
        [Test]
        public void Preset_MatchesSiteDefaults()
        {
            var preset = ScriptableObject.CreateInstance<RadiantBeamPreset>();

            Assert.That(ColorUtility.ToHtmlStringRGB(preset.color), Is.EqualTo("FFE3A0"));
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
            var effect = root.AddComponent<RadiantBeamEffect>();

            Assert.That(effect.LayerCounts(0.5f), Is.EqualTo(new Vector2Int(256, 0)));

            Object.DestroyImmediate(root);
        }

        [Test]
        public void Body_HasNoInvalidVertices()
        {
            Mesh mesh = RadiantBeamMeshes.CreateBody();

            Assert.That(mesh.vertexCount, Is.EqualTo(2 * 33 * 11 + 2 * (49 * 5 + 7 * 19 * 7)));
            foreach (Vector3 vertex in mesh.vertices)
            {
                Assert.That(float.IsNaN(vertex.x + vertex.y + vertex.z), Is.False);
            }

            Object.DestroyImmediate(mesh);
        }
    }
}
