Shader "Custom/ForceShield"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_TintColor ("Shield Color", Color) = (1, 1, 1, 1)
		_BumpMap ("Normal Texture", 2D) = "bump" {}
		_BumpStrength ("Normal Strength", Range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
				
				float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
				
				float3 worldNormal : NORMAL;
            };

            sampler2D _MainTex, _BumpMap;
            float4 _MainTex_ST, _BumpMap_ST;

			half4 _TintColor;
			half _NormalStrength;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv + _MainTex_ST);
				//fixed4 col = tex2D(_MainTex, UnpackNormal(tex2D(_BumpMap, i.uv * _NormalStrength)));

				//blend between texture color and tint color
				col.rgb = sqrt((1 - _TintColor.a) * pow(col.rgb, 2) + _TintColor.a * pow(_TintColor.rgb, 2));

				//simple additive
				//col.rgb = min(col.rgb + (_TintColor.rgb * _TintColor.a), half3(1.0, 1.0, 1.0));

				//average additive
				//col.rgb = (_TintColor.rgb + col.rgb) / 2.0;

                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
