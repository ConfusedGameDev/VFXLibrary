using System;
using System.Collections.Generic;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Showcase
{
    /// <summary>How a bay presents an item.</summary>
    public enum VfxShowcaseDisplay
    {
        Projectile,
        Beam,
        Blade,
        Sweep,
        Effect,
        ImpactFrame,
        Held,
        Placed
    }

    [Serializable]
    public sealed class VfxShowcaseItem
    {
        public string name;
        public string description;
        public VfxShowcaseDisplay display;
        [Tooltip("Empty only for ImpactFrame, which is a component rather than a prefab.")]
        public GameObject prefab;
        [Tooltip("Height of the origin above the floor.")]
        public float height;
        public float scale = 1f;
    }

    [Serializable]
    public sealed class VfxShowcaseCategory
    {
        public string name;
        [Tooltip("Lists the category under Objects in the menu, rather than Effects.")]
        public bool objects;
        public List<VfxShowcaseItem> items = new List<VfxShowcaseItem>();
    }

    /// <summary>Everything the hall can show, by menu category.</summary>
    public sealed class VfxShowcaseCatalog : ScriptableObject
    {
        public List<VfxShowcaseCategory> categories = new List<VfxShowcaseCategory>();

        [Header("Bay props")]
        [Tooltip("Holds the shooter in projectile bays.")]
        public GameObject shootingWeapon;
        [Tooltip("Emits the beam in beam bays.")]
        public GameObject beamTurret;
        public GameObject sword;
    }
}
