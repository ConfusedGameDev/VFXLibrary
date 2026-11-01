#ifndef CONFUSEDGAMEDEV_ELECTRIC_ARROW_COMMON_INCLUDED
#define CONFUSEDGAMEDEV_ELECTRIC_ARROW_COMMON_INCLUDED

#define _Flight _Motion0.x
#define _Cutoff _Motion0.y
#define _ImpactClock _Motion0.z
#define _Charge _LifeStart

float End()
{
    return _LifeStage > 1.5 ? _LifeEnd : -1.0;
}

float ArrowHash(float n)
{
    return frac(sin(n * 127.1 + 311.7) * 43758.5453);
}

float ArrowFade()
{
    float end = End();
    return end < 0.0 ? 1.0 : 1.0 - smoothstep(0.0, _Impact > 0.5 ? 0.10 : 1.0, end);
}

float Charged()
{
    return smoothstep(0.0, 0.2, _Charge);
}

// Five times the energy at contact, drained within 90ms. The range stays the same.
float ContactPunch(float age)
{
    return 1.0 + 4.0 * (1.0 - smoothstep(0.012, 0.09, max(0.0, age)));
}

#endif
