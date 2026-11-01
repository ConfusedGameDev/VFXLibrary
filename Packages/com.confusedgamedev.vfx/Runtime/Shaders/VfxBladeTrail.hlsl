#ifndef CONFUSEDGAMEDEV_VFX_BLADE_TRAIL_INCLUDED
#define CONFUSEDGAMEDEV_VFX_BLADE_TRAIL_INCLUDED

// The weapon trails' ribbon. Positions are already in the effect's local space, in Unity's axes.

#include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxCommon.hlsl"

struct Attributes
{
    float3 positionOS : POSITION;
    float2 uv : TEXCOORD0;
    float2 age : TEXCOORD1;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float4 positionCS : SV_POSITION;
    float2 uv : TEXCOORD0;
    float age : TEXCOORD1;
    float4 screen : TEXCOORD2;
    UNITY_VERTEX_OUTPUT_STEREO
};

Varyings Vert(Attributes input)
{
    Varyings output = (Varyings)0;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
    output.uv = input.uv;
    output.age = input.age.x;
    output.positionCS = TransformObjectToHClip(input.positionOS);
    output.screen = ComputeScreenPos(output.positionCS);
    return output;
}

// Fine lines along the blade, as many as density allows. _Quantity carries the density here.
float BladeLines(float y, float width)
{
    float lines = 0.0;
    float aa = max(fwidth(y), 0.002);
    for (int i = 0; i < 8; i++)
    {
        float center = 0.12 + i * 0.105;
        lines += (1.0 - smoothstep(width, width + aa, abs(y - center))) * step(i + 0.5, _Quantity * 8.0);
    }
    return lines;
}

#endif
