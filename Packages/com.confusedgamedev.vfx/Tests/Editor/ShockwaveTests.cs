using NUnit.Framework;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Tests
{
    public class ShockwaveTests
    {
        [Test]
        public void Preset_MatchesSiteDefaults()
        {
            var preset = ScriptableObject.CreateInstance<ShockwavePreset>();

            Assert.That(ColorUtility.ToHtmlStringRGB(preset.color), Is.EqualTo("F0CF9D"));
            Assert.That(preset.density, Is.EqualTo(0.5f));
            Assert.That(preset.duration, Is.EqualTo(2.8f));
            Assert.That(preset.stopDuration, Is.EqualTo(0f));
            Assert.That(preset.playback, Is.EqualTo(VfxPlayback.OneShot));

            Object.DestroyImmediate(preset);
        }

        [Test]
        public void LayerCounts_SplitTheBudgetLikeTheSource()
        {
            Assert.That(ShockwaveMeshes.LayerCounts(0.5f), Is.EqualTo(new Vector4(187f, 36f, 12f, 14f)));
        }

        [Test]
        public void Chips_HasNoInvalidVertices()
        {
            Mesh mesh = ShockwaveMeshes.CreateChips();

            Assert.That(mesh.vertexCount, Is.EqualTo(336));
            foreach (Vector3 vertex in mesh.vertices)
            {
                Assert.That(float.IsNaN(vertex.x + vertex.y + vertex.z), Is.False);
            }

            Object.DestroyImmediate(mesh);
        }
    }
}
