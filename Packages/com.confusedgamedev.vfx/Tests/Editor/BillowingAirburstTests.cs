using NUnit.Framework;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Tests
{
    public class BillowingAirburstTests
    {
        [Test]
        public void Preset_MatchesSiteDefaults()
        {
            var preset = ScriptableObject.CreateInstance<BillowingAirburstPreset>();

            Assert.That(ColorUtility.ToHtmlStringRGB(preset.color), Is.EqualTo("FF7A24"));
            Assert.That(preset.density, Is.EqualTo(0.5f));
            Assert.That(preset.duration, Is.EqualTo(2.4f));
            Assert.That(preset.stopDuration, Is.EqualTo(0f));
            Assert.That(preset.playback, Is.EqualTo(VfxPlayback.OneShot));
            Assert.That(preset.Quantity, Is.EqualTo(4));

            Object.DestroyImmediate(preset);
        }

        [Test]
        public void LayerCounts_SplitTheBudgetLikeTheSource()
        {
            Assert.That(BillowingAirburstMeshes.LayerCounts(0.5f), Is.EqualTo(new Vector4(64f, 0f, 0f, 0f)));
        }

        [Test]
        public void Jets_HasNoInvalidVertices()
        {
            Mesh mesh = BillowingAirburstMeshes.CreateJets();

            Assert.That(mesh.vertexCount, Is.EqualTo(45360));
            foreach (Vector3 vertex in mesh.vertices)
            {
                Assert.That(float.IsNaN(vertex.x + vertex.y + vertex.z), Is.False);
            }

            Object.DestroyImmediate(mesh);
        }

        [Test]
        public void RollCast_KeepsJetsApartAndRepeatsForASeed()
        {
            var first = new Vector4[GoldenPaths];
            var second = new Vector4[GoldenPaths];
            var bends = new Vector4[GoldenPaths];

            Vector4 offset = BillowingAirburstMeshes.RollCast(5u, first, bends);
            Assert.That(BillowingAirburstMeshes.RollCast(5u, second, bends), Is.EqualTo(offset));
            Assert.That(second, Is.EqualTo(first));
            for (int i = 0; i < GoldenPaths; i++)
            {
                for (int j = 0; j < i; j++)
                {
                    Assert.That(Vector3.Dot(first[i], first[j]), Is.LessThan(0.78f));
                }
            }
        }

        private const int GoldenPaths = BillowingAirburstMeshes.Jets;
    }
}
