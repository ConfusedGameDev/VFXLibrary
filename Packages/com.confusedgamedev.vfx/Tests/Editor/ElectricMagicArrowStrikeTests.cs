using NUnit.Framework;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Tests
{
    public class ElectricMagicArrowStrikeTests
    {
        [Test]
        public void Preset_MatchesSiteDefaults()
        {
            var preset = ScriptableObject.CreateInstance<ElectricMagicArrowStrikePreset>();

            Assert.That(ColorUtility.ToHtmlStringRGB(preset.color), Is.EqualTo("FFD36A"));
            Assert.That(preset.density, Is.EqualTo(0.5f));
            Assert.That(preset.startDuration, Is.EqualTo(1.2f));
            Assert.That(preset.stopDuration, Is.EqualTo(1.4f));
            Assert.That(preset.playback, Is.EqualTo(VfxPlayback.Looping));

            Object.DestroyImmediate(preset);
        }

        [Test]
        public void Core_IsFlatShaded()
        {
            Mesh mesh = ElectricMagicArrowStrikeMeshes.CreateCore();

            Assert.That(mesh.vertexCount, Is.EqualTo(112 * 3));
            foreach (Vector3 normal in mesh.normals)
            {
                Assert.That(float.IsNaN(normal.x + normal.y + normal.z), Is.False);
            }

            Object.DestroyImmediate(mesh);
        }

        [Test]
        public void Discharge_SameSeedDrawsTheSameLightning()
        {
            var first = new ElectricArrowDischarge(7u);
            var second = new ElectricArrowDischarge(7u);

            first.SyncArrow(0.8f, false);
            second.SyncArrow(0.8f, false);
            Assert.That(first.Arcs.Mesh.vertices, Is.EqualTo(second.Arcs.Mesh.vertices));
            Assert.That(first.Arcs.Mesh.vertexCount, Is.EqualTo(32 * 33 * 2));

            first.Release();
            second.Release();
        }

        [Test]
        public void Discharge_ArcsStayBehindTheTip()
        {
            var discharge = new ElectricArrowDischarge(11u);

            discharge.SyncArrow(1.15f, false);
            foreach (Vector3 vertex in discharge.Arcs.Mesh.vertices)
            {
                Assert.That(vertex.x, Is.LessThanOrEqualTo(1.72f));
            }

            discharge.Release();
        }
    }
}
