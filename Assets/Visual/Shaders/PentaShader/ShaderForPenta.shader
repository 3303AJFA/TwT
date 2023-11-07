Shader "CustomShaders/ShaderForPenta"
{
    Properties
    {
        _ColorA("Color A", Color) = (1,1,1,1)
        _ColorB("Color B", Color) = (1,1,1,1)
        _ColorStart ("Color Start", Range(0,1) ) = 0
        _ColorEnd ("Color End", Range(0,1) ) = 1
    }
    SubShader
    {
        Tags { 
                "RenderType"="Transparent" 
                "Queue"="Transparent" }

        Pass
        {
            Cull Off
            ZWrite Off
            Blend One One // additive
            
            
            //Blend DstColor Zero // multiply
            
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            #define TAU 6.28318530718

            float4 _ColorB;
            float4 _ColorA;
            float _ColorStart;
            float _ColorEnd;
            
            struct MeshData
            {
                float4 vertex : POSITION;
                float3 normals: NORMAL;
                float4 uv0 : TEXCOORD0;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD0;
                float2 uv : TEXCOORD1;
            };

            

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normals);
                o.uv = v.uv0;//(v.uv0 + _Offset) * _Scale;
                return o;
            }

            float InverseLerp (float a, float b, float v)
            {
                return (v-a)/(b-a);
            }

            fixed4 frag (Interpolators i) : SV_Target
            {
                //float t = saturate (InverseLerp(_ColorStart, _ColorEnd, i.uv.x));
                //float4 t = abs(frac(i.uv.x * 5) * 2 - 1);

                float xOffset = cos( i.uv.x * TAU * 8) * 0.01;
                float t = cos((i.uv.y + xOffset - _Time.y * 0.1) * TAU * 5) * 0.5 + 0.5;
                t *= 1 - i.uv.y;

                float topBottomRemover = (abs(i.normal.y) < 0.999);
                float waves = t * topBottomRemover;
                
                float4 gradient = lerp(_ColorA, _ColorB, i.uv.y);
                
                return gradient * waves;
            }
            ENDCG
        }
    }
}
