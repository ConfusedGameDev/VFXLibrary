using NUnit.Framework;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Tests
{
    public class MagmaFissureTests
    {
        [Test]
        public void Preset_MatchesSiteDefaults()
        {
            var preset = ScriptableObject.CreateInstance<MagmaFissurePreset>();

            Assert.That(ColorUtility.ToHtmlStringRGB(preset.color), Is.EqualTo("FF823E"));
            Assert.That(preset.density, Is.EqualTo(0.5f));
            Assert.That(preset.duration, Is.EqualTo(1.8f));
            Assert.That(preset.stopDuration, Is.EqualTo(0f));
            Assert.That(preset.playback, Is.EqualTo(VfxPlayback.OneShot));
            Assert.That(preset.Quantity, Is.EqualTo(13));

            Object.DestroyImmediate(preset);
        }

        [Test]
        public void LayerCounts_SplitTheBudgetLikeTheSource()
        {
            Assert.That(MagmaFissureMeshes.LayerCounts(0.5f), Is.EqualTo(new Vector4(256f, 0f, 0f, 0f)));
        }

        [Test]
        public void Body_HasNoInvalidVertices()
        {
            Mesh mesh = MagmaFissureMeshes.CreateBody();

            Assert.That(mesh.vertexCount, Is.EqualTo(7584));
            foreach (Vector3 vertex in mesh.vertices)
            {
                Assert.That(float.IsNaN(vertex.x + vertex.y + vertex.z), Is.False);
            }

            Object.DestroyImmediate(mesh);
        }
    }
}
