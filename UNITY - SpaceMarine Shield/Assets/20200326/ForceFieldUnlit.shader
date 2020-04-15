Shader "Unlit/ForceFieldUnlit"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

		[Header(Normalmap Distortion)]
		_NormalMap ("Normal Map", 2D) = "bump" {}
		_NormalStrength ("Normal Strength", Range(0, 1)) = 1
		_normalTiling ("Normal Tiling", Vector) = (0, 0, 0, 0)
		_normalOffset ("Normal Offset", Vector) = (0, 0, 0, 0)

		[Header(Rim Effect)]
		[HDR] _RimColor ("Rim Color", Color) = (1,1,1,1)
		[HDR] _OuterRimColor ("Outer Rim Color", Color) = (1,1,1,1)
		[PowerSlider(2)] _RimWidth ("Rim width", Range(0.5, 3)) = 2
    }
    SubShader
    {
        Tags { "Queue"= "Transparent" "RenderType"="Transparent" }
		Blend SrcAlpha OneMinusSrcAlpha
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
				float2 uv2 : TEXCOORD1;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
				float4 screenPosition : TEXCOORD2;
				
				float3 viewDir : TEXCOORD3;
				float3 normal : NORMAL;
            };

            sampler2D _MainTex;
			sampler2D _NormalMap;
            float4 _MainTex_ST, _NormalMap_ST;
			float _NormalStrength;
			float2 _normalTiling, _normalOffset;
			
			float4 _RimColor, _OuterRimColor;
			float _RimWidth;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.uv2 = TRANSFORM_TEX(v.uv, _NormalMap);
				o.screenPosition = ComputeScreenPos(o.vertex);
				
				o.viewDir = normalize(_WorldSpaceCameraPos - mul(unity_ObjectToWorld, v.vertex).xyz);
				o.normal = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject).xyz);

                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				//Calculate distortion, and apply background texture.
				float2 uvModifier = UnpackNormal(tex2D(_NormalMap, (i.uv2 * _normalTiling) + (_normalOffset * _Time.x))) * _NormalStrength;

				float2 textureCoord = (i.screenPosition.xy / i.screenPosition.w) + uvModifier;
				float4 col = tex2D(_MainTex, textureCoord);


				float rim = 1.0 - abs(dot(i.viewDir, i.normal));
				float outerRim = pow(rim, 4.0);
				rim = pow(rim, _RimWidth);
				//col.a = rim; //used to fade albedo of the object

				col.rgb += rim * _RimColor;
				col.rgb += outerRim * _OuterRimColor;

				UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
