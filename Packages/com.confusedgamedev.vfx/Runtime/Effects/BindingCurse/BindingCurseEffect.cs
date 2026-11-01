namespace ConfusedGameDev.Vfx
{
    /// <summary>Hooked Binding Sigil. Curved hooked bands rise from a three-armed sigil and tighten in turn.</summary>
    public sealed class BindingCurseEffect : VfxGroundEffect
    {
        protected override int MaxParticles => BindingCurseMeshes.MaxParticles;
    }
}
