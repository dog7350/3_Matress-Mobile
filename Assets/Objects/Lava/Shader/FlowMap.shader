Shader "Flowing Lava Surface/Flow Map" {
	Properties {
		_MainTex ("Main", 2D) = "white" {}
		_FlowMap ("Flow", 2D) = "grey" {}
		_Speed ("Speed", Range(-0.3, 0.3)) = 0.2
		_MaskTex ("Mask", 2D) = "white" {}
		_AlbedoTex ("Albedo", 2D) = "white" {}
	}
	SubShader {
		Tags { "RenderType" = "Opaque" }
		Pass {
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			sampler2D _MainTex, _FlowMap, _MaskTex, _AlbedoTex;
			fixed4 _MainTex_ST, _MaskTex_ST, _AlbedoTex_ST;
			fixed _Speed;

			struct v2f
			{
				float4 pos : SV_POSITION;
				fixed2 uv : TEXCOORD0;
				fixed4 uv2 : TEXCOORD1;
			};
			v2f vert (appdata_base v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.uv2.xy = TRANSFORM_TEX(v.texcoord, _MaskTex);
				o.uv2.zw = TRANSFORM_TEX(v.texcoord, _AlbedoTex);
				return o;
			}
			fixed4 frag (v2f i) : SV_TARGET
			{
				half3 f = (tex2D(_FlowMap, i.uv) * 2 - 1) * _Speed;
				float dif1 = frac(_Time.y * 0.25 + 0.5);
				float dif2 = frac(_Time.y * 0.25);
				half l = abs((0.5 - dif1) / 0.5);
				half4 c1 = tex2D(_MainTex, i.uv - f.xy * dif1);
				half4 c2 = tex2D(_MainTex, i.uv - f.xy * dif2);
				fixed4 lava = lerp(c1, c2, l);
				
				fixed4 mask = tex2D(_MaskTex, i.uv2.xy);
				fixed4 albedo = tex2D(_AlbedoTex, i.uv2.zw);
				return lerp(albedo, lava, mask.r);
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}
