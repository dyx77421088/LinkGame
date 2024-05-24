Shader "Custom/FireFlame"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200


        Pass
        {
            HLSLINCLUDE
            float2 Hash12(float2 p)
            {
                return frac(sin(dot(p, float2(12.9898, 78.233))) * 43758.5453);
            }

            float Noise(float2 p)
            {
                float2 i = floor(p);
                float2 f = frac(p);
                f = f * f * (3.0 - 2.0 * f);

                float a = Hash12(i).x + Hash12(i + float2(1.0, 0.0)).x;
                float b = Hash12(i + float2(0.0, 1.0)).x + Hash12(i + float2(1.0, 1.0)).x;

                return lerp(a, b, f.y) * (1.0 - f.x) + lerp(a, b, f.y + 1.0) * f.x;
            }

            float FireNoise(float2 uv)
            {
                float time = _Time.y; // 使用时间来控制火焰动态效果
                float freq = 2.0; // 噪声频率
                float scale = 10.0; // 缩放参数

                float noise = 0.0;
                float amplitude = 0.5;

                for (int i = 0; i < 4; i++)
                {
                    noise += amplitude * Noise(uv * freq + float2(0.0, time));
                    freq *= 2.0;
                    amplitude *= 0.5;
                    uv *= scale;
                }

                return noise;
            }
            #pragma surface surf Lambert

            sampler2D _MainTex;

            struct Input
            {
                float2 uv_MainTex;
            };

            void surf (Input IN, inout SurfaceOutput o)
            {
                // 使用噪声函数生成火焰效果
                float noise = FireNoise(IN.uv_MainTex);

                // 将噪声值转为颜色输出
                o.Albedo = float3(1.0, 0.5 * noise, 0.0);
            }
            ENDHLSL
        }
    }
}