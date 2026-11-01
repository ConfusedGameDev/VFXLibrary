using NUnit.Framework;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Tests
{
    public class BlackHoleTests
    {
        [Test]
        public void Preset_MatchesSiteDefaults()
        {
            var preset = ScriptableObject.CreateInstance<BlackHolePreset>();

            Assert.That(ColorUtility.ToHtmlStringRGB(preset.color), Is.EqualTo("FFAB42"));
            Assert.That(preset.density, Is.EqualTo(1f));
            Assert.That(preset.holeSize, Is.EqualTo(6f));
            Assert.That(preset.holeDetail, Is.EqualTo(2f));
            Assert.That(preset.playback, Is.EqualTo(VfxPlayback.Looping));
            Assert.That(preset.startDuration, Is.EqualTo(1.1f));
            Assert.That(preset.stopDuration, Is.EqualTo(1.4f));

            Object.DestroyImmediate(preset);
        }

        [Test]
        public void RearDisk_HasNoInvalidVertices()
        {
            Mesh mesh = BlackHoleMeshes.CreateRearDisk();

            Assert.That(mesh.vertexCount, Is.EqualTo(2093));
            foreach (Vector3 vertex in mesh.vertices)
            {
                Assert.That(float.IsNaN(vertex.x + vertex.y + vertex.z), Is.False);
            }

            Object.DestroyImmediate(mesh);
        }
    }
}
