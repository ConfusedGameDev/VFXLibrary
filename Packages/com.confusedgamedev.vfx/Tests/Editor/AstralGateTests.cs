using NUnit.Framework;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Tests
{
    public class AstralGateTests
    {
        [Test]
        public void Preset_MatchesSiteDefaults()
        {
            var preset = ScriptableObject.CreateInstance<AstralGatePreset>();

            Assert.That(ColorUtility.ToHtmlStringRGB(preset.color), Is.EqualTo("C1B8FF"));
            Assert.That(preset.density, Is.EqualTo(0.5f));
            Assert.That(preset.playback, Is.EqualTo(VfxPlayback.Looping));
            Assert.That(preset.startDuration, Is.EqualTo(0.8f));
            Assert.That(preset.stopDuration, Is.EqualTo(0.8f));

            Object.DestroyImmediate(preset);
        }

        [Test]
        public void Frame_HasNoInvalidVertices()
        {
            Mesh mesh = AstralGateMeshes.CreateFrame();

            Assert.That(mesh.vertexCount, Is.EqualTo(2688));
            foreach (Vector3 vertex in mesh.vertices)
            {
                Assert.That(float.IsNaN(vertex.x + vertex.y + vertex.z), Is.False);
            }

            Object.DestroyImmediate(mesh);
        }
    }
}
