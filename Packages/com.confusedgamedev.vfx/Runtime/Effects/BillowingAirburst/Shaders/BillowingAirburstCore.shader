Shader "ConfusedGameDev/Vfx/BillowingAirburst Core"
{
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Opaque" "Queue" = "Geometry+1" }

        Pass
        {
            Name "Forward"
            Tags { "LightMode" = "UniversalForward" }
            Blend One Zero
            ZWrite On
            Cull Front

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag

            #define VFX_VARIANT 11
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxBurst.hlsl"
            #include "BillowingAirburstCommon.hlsl"

            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 lobe : TEXCOORD1;
                float4 data : TEXCOORD2;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 surface : TEXCOORD0;
                float3 normalVS : TEXCOORD1;
                float3 view : TEXCOORD2;
                float3 state : TEXCOORD3;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            float3 Surface(float3 p, float t, float4 data)
            {
                float turn = t * (0.52 + data.w * 0.40);
                float c = cos(turn);
                float s = sin(turn);
                float3 r = float3(c * p.x + s * p.z, p.y, -s * p.x + c * p.z);
                float rolling = sin(r.x * 3.1 + t * 0.8 + data.x * 6.0) * sin(r.y * 3.4 - t * 0.6 + data.w * 5.0) * sin(r.z * 2.6 + t * 0.5);
                float broad = Noise3(r * 2.1 + _BurstOffset + float3(0.0, -t * 0.25, 0.0));
                float curls = Sq(0.5 + 0.5 * sin(r.x * 5.0 + t * 0.55 + data.x * 7.0) * cos(r.y * 4.0 - t * 0.45) * sin(r.z * 4.5 + t * 0.3));
                float shape = 1.0 + rolling * (0.08 + 0.045 * _EffectDetail) + (broad - 0.5) * 0.14 + curls * (0.13 + 0.055 * _EffectDetail);
                return r * shape;
            }

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                float t = _EffectTime;
                float4 data = input.data;
                if (t <= 0.0 || t >= 2.11)
                {
                    return output;
                }

                #ifdef AIRBURST_JETS
                    if (data.y >= round(_Quantity))
                    {
                        return output;
                    }
                #endif

                float3 position = input.positionOS;
                float3 normal = input.normalOS;
                float3 p = Surface(position, t, data);
                float3 tangent = normalize(cross(normal, abs(normal.y) > 0.98 ? float3(1.0, 0.0, 0.0) : float3(0.0, 1.0, 0.0)));
                float3 bitangent = cross(normal, tangent);
                float3 dx = Surface(normalize(position + tangent * 0.012), t, data) - p;
                float3 dy = Surface(normalize(position + bitangent * 0.012), t, data) - p;
                float3 center;
                float swell, age;
                LobeMotion(t, input.lobe, data, center, swell, age);
                float3 localNormal = normalize(cross(dx, dy));
                #ifdef AIRBURST_JETS
                    float3 d = _JetPaths[(int)data.y].xyz;
                    p = d * dot(p, d) * 1.24 + (p - d * dot(p, d));
                    localNormal -= d * dot(localNormal, d) * (1.0 - 1.0 / 1.24);
                #else
                    p *= float3(1.08, 0.94, 1.0);
                    localNormal /= float3(1.08, 0.94, 1.0);
                #endif

                p = center + p * input.lobe.w * swell;
                float3 positionVS = SourceToView(p * _EffectSize);
                output.surface = p;
                output.normalVS = SourceDirToView(normalize(localNormal));
                output.view = positionVS;
                output.state = float3(data.x, data.z, age);
                output.positionCS = TransformWViewToHClip(positionVS);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                #ifdef AIRBURST_JETS
                    if (input.state.z <= 0.001)
                    {
                        discard;
                    }
                #endif

                float t = _EffectTime;
                float along = input.state.y;
                float3 flow = input.surface * 1.65 + _BurstOffset + float3(0.0, -t * 0.36, t * 0.12);
                float broad = Billow(flow);
                float fine = Noise3(flow * 3.0);
                float localTime = t - input.state.x * 0.14 - along * 0.08;
                float erosion = smoothstep(0.72, 2.16, localTime);
                float matter = broad * 0.72 + fine * 0.12 + 0.22;
                float coverage = smoothstep(-0.035, 0.065, matter - erosion);
                coverage *= 1.0 - smoothstep(1.8, 2.4, t);
                if (coverage < 0.48)
                {
                    discard;
                }

                float3 n = normalize(input.normalVS);
                float3 viewDirection = normalize(-input.view);
                float3 keyLight = normalize(TransformWorldToViewDir(ToUnity(float3(-0.45, 0.8, 0.45))));
                float diffuse = max(0.0, dot(n, keyLight));
                float rim = pow(abs(1.0 - max(0.0, dot(n, viewDirection))), 1.65);
                float heatAge = t;
                #ifdef AIRBURST_JETS
                    heatAge = t - along * 0.22;
                #endif

                float burn = FlameHeat(heatAge, broad);
                float hot = burn * (0.78 + (broad - 0.5) * 1.0 + rim * 0.17);
                float whiteHot = pow(smoothstep(0.50, 0.94, hot), 1.4);
                float3 soot = lerp(float3(0.0004, 0.00025, 0.00018), float3(0.008, 0.005, 0.003), pow(diffuse, 1.1));
                soot *= 0.80 + broad * 0.30;
                float3 warmSurface = HeatColor(_EffectColor.rgb, 0.50) * (0.8 + burn * 1.6) * (0.30 + 0.70 * diffuse) * 0.5;
                float3 hotEmission = float3(1.0, 0.96, 0.79) * (1.0 + burn * 3.0) * 0.5;
                float3 thermalMix = float3(whiteHot, whiteHot, whiteHot * whiteHot);
                float3 fire = lerp(1.0 - exp(-warmSurface), 1.0 - exp(-hotEmission), thermalMix);
                float3 color = lerp(soot, fire, smoothstep(0.20, 0.72, burn));
                float residual = (1.0 - smoothstep(0.40, 1.08, heatAge)) * (1.0 - burn);
                float seams = pow(smoothstep(0.35, 0.72, broad), 1.35);
                float hotEdges = (rim * 1.35 + pow(max(0.0, broad - 0.48) * 2.0, 3.0) * 0.45) * seams;
                float3 edgeLight = HeatColor(_EffectColor.rgb, 0.78 + hotEdges * 0.28) * hotEdges * residual * 1.5;
                color += (1.0 - color) * (1.0 - exp(-edgeLight));
                return float4(color, 1.0);
            }

            float4 FragDepth(Varyings input) : SV_Target
            {
                Frag(input);
                return input.positionCS.z;
            }
            ENDHLSL
        }

        Pass
        {
            Name "DepthOnly"
            Tags { "LightMode" = "DepthOnly" }
            ColorMask R
            ZWrite On
            Cull Front

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment FragDepth

            #define VFX_VARIANT 11
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxBurst.hlsl"
            #include "BillowingAirburstCommon.hlsl"

            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 lobe : TEXCOORD1;
                float4 data : TEXCOORD2;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 surface : TEXCOORD0;
                float3 normalVS : TEXCOORD1;
                float3 view : TEXCOORD2;
                float3 state : TEXCOORD3;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            float3 Surface(float3 p, float t, float4 data)
            {
                float turn = t * (0.52 + data.w * 0.40);
                float c = cos(turn);
                float s = sin(turn);
                float3 r = float3(c * p.x + s * p.z, p.y, -s * p.x + c * p.z);
                float rolling = sin(r.x * 3.1 + t * 0.8 + data.x * 6.0) * sin(r.y * 3.4 - t * 0.6 + data.w * 5.0) * sin(r.z * 2.6 + t * 0.5);
                float broad = Noise3(r * 2.1 + _BurstOffset + float3(0.0, -t * 0.25, 0.0));
                float curls = Sq(0.5 + 0.5 * sin(r.x * 5.0 + t * 0.55 + data.x * 7.0) * cos(r.y * 4.0 - t * 0.45) * sin(r.z * 4.5 + t * 0.3));
                float shape = 1.0 + rolling * (0.08 + 0.045 * _EffectDetail) + (broad - 0.5) * 0.14 + curls * (0.13 + 0.055 * _EffectDetail);
                return r * shape;
            }

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                float t = _EffectTime;
                float4 data = input.data;
                if (t <= 0.0 || t >= 2.11)
                {
                    return output;
                }

                #ifdef AIRBURST_JETS
                    if (data.y >= round(_Quantity))
                    {
                        return output;
                    }
                #endif

                float3 position = input.positionOS;
                float3 normal = input.normalOS;
                float3 p = Surface(position, t, data);
                float3 tangent = normalize(cross(normal, abs(normal.y) > 0.98 ? float3(1.0, 0.0, 0.0) : float3(0.0, 1.0, 0.0)));
                float3 bitangent = cross(normal, tangent);
                float3 dx = Surface(normalize(position + tangent * 0.012), t, data) - p;
                float3 dy = Surface(normalize(position + bitangent * 0.012), t, data) - p;
                float3 center;
                float swell, age;
                LobeMotion(t, input.lobe, data, center, swell, age);
                float3 localNormal = normalize(cross(dx, dy));
                #ifdef AIRBURST_JETS
                    float3 d = _JetPaths[(int)data.y].xyz;
                    p = d * dot(p, d) * 1.24 + (p - d * dot(p, d));
                    localNormal -= d * dot(localNormal, d) * (1.0 - 1.0 / 1.24);
                #else
                    p *= float3(1.08, 0.94, 1.0);
                    localNormal /= float3(1.08, 0.94, 1.0);
                #endif

                p = center + p * input.lobe.w * swell;
                float3 positionVS = SourceToView(p * _EffectSize);
                output.surface = p;
                output.normalVS = SourceDirToView(normalize(localNormal));
                output.view = positionVS;
                output.state = float3(data.x, data.z, age);
                output.positionCS = TransformWViewToHClip(positionVS);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                #ifdef AIRBURST_JETS
                    if (input.state.z <= 0.001)
                    {
                        discard;
                    }
                #endif

                float t = _EffectTime;
                float along = input.state.y;
                float3 flow = input.surface * 1.65 + _BurstOffset + float3(0.0, -t * 0.36, t * 0.12);
                float broad = Billow(flow);
                float fine = Noise3(flow * 3.0);
                float localTime = t - input.state.x * 0.14 - along * 0.08;
                float erosion = smoothstep(0.72, 2.16, localTime);
                float matter = broad * 0.72 + fine * 0.12 + 0.22;
                float coverage = smoothstep(-0.035, 0.065, matter - erosion);
                coverage *= 1.0 - smoothstep(1.8, 2.4, t);
                if (coverage < 0.48)
                {
                    discard;
                }

                float3 n = normalize(input.normalVS);
                float3 viewDirection = normalize(-input.view);
                float3 keyLight = normalize(TransformWorldToViewDir(ToUnity(float3(-0.45, 0.8, 0.45))));
                float diffuse = max(0.0, dot(n, keyLight));
                float rim = pow(abs(1.0 - max(0.0, dot(n, viewDirection))), 1.65);
                float heatAge = t;
                #ifdef AIRBURST_JETS
                    heatAge = t - along * 0.22;
                #endif

                float burn = FlameHeat(heatAge, broad);
                float hot = burn * (0.78 + (broad - 0.5) * 1.0 + rim * 0.17);
                float whiteHot = pow(smoothstep(0.50, 0.94, hot), 1.4);
                float3 soot = lerp(float3(0.0004, 0.00025, 0.00018), float3(0.008, 0.005, 0.003), pow(diffuse, 1.1));
                soot *= 0.80 + broad * 0.30;
                float3 warmSurface = HeatColor(_EffectColor.rgb, 0.50) * (0.8 + burn * 1.6) * (0.30 + 0.70 * diffuse) * 0.5;
                float3 hotEmission = float3(1.0, 0.96, 0.79) * (1.0 + burn * 3.0) * 0.5;
                float3 thermalMix = float3(whiteHot, whiteHot, whiteHot * whiteHot);
                float3 fire = lerp(1.0 - exp(-warmSurface), 1.0 - exp(-hotEmission), thermalMix);
                float3 color = lerp(soot, fire, smoothstep(0.20, 0.72, burn));
                float residual = (1.0 - smoothstep(0.40, 1.08, heatAge)) * (1.0 - burn);
                float seams = pow(smoothstep(0.35, 0.72, broad), 1.35);
                float hotEdges = (rim * 1.35 + pow(max(0.0, broad - 0.48) * 2.0, 3.0) * 0.45) * seams;
                float3 edgeLight = HeatColor(_EffectColor.rgb, 0.78 + hotEdges * 0.28) * hotEdges * residual * 1.5;
                color += (1.0 - color) * (1.0 - exp(-edgeLight));
                return float4(color, 1.0);
            }

            float4 FragDepth(Varyings input) : SV_Target
            {
                Frag(input);
                return input.positionCS.z;
            }
            ENDHLSL
        }
    }
}
