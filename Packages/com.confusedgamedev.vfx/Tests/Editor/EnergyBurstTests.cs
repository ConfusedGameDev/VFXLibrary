using NUnit.Framework;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Tests
{
    public class EnergyBurstTests
    {
        [Test]
        public void Preset_MatchesSiteDefaults()
        {
            var preset = ScriptableObject.CreateInstance<EnergyBurstPreset>();

            Assert.AreEqual(12, preset.quantity);
            Assert.AreEqual(2.8f, preset.duration);
            Assert.AreEqual(0x28 / 255f, preset.color.r, 0.001f);
            Assert.AreEqual(1f, preset.color.b, 0.001f);

            Object.DestroyImmediate(preset);
        }

        [TestCase(1f)]
        [TestCase(0.5f)]
        [TestCase(0.1f)]
        public void LayerCounts_SpendTheWholeBudget(float density)
        {
            Vector3Int counts = EnergyBurstMeshes.LayerCounts(density);

            Assert.AreEqual(Mathf.RoundToInt(EnergyBurstMeshes.MaxParticles * density), counts.x + counts.y + counts.z);
            Assert.LessOrEqual(counts.y, EnergyBurstMeshes.MaxClouds);
            Assert.LessOrEqual(counts.z, EnergyBurstMeshes.MaxFragments);
        }

        [Test]
        public void Arcs_HaveOneQuadPerStep()
        {
            Mesh mesh = EnergyBurstMeshes.CreateArcs();

            // 24 main arcs of 64 steps and 48 forks of 16.
            Assert.AreEqual((24 * 64 + 48 * 16) * 4, mesh.vertexCount);

            Object.DestroyImmediate(mesh);
        }
    }
}
