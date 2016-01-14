Shader "Hidden/SmokeBlur" {
	Properties {
		_MainTex ("Texture", 2D) = "white" {}
		_Accum ("Accumulation", Range(0.01, 1)) = 0.01
		_Atten ("Attenuation", Range(0, 1)) = 0.01
	}
	SubShader {
		Cull Off ZWrite Off ZTest Always

		CGINCLUDE
		struct appdata {
			float4 vertex : POSITION;
			float2 uv : TEXCOORD0;
		};
		struct v2f {
			float2 uv : TEXCOORD0;
			float4 vertex : SV_POSITION;
		};

		sampler2D _MainTex;
		float4 _MainTex_TexelSize;
		float4x4 _BlurMat;
		float _Accum;
		float _Atten;

		v2f vert (appdata v) {
			v2f o;
			o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
			o.uv = v.uv;
			return o;
		}
		ENDCG

		// Accumulation
		Pass {
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma target 5.0
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			
			fixed4 frag (v2f i) : SV_Target {
				fixed4 c = tex2D(_MainTex, i.uv);
				return float4(c.rgb, c.a * _Accum);
			}
			ENDCG
		}

		// Blur
		Pass {
			CGPROGRAM
			#pragma target 5.0
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			
			fixed4 frag (v2f i) : SV_Target {
				float2 d = _MainTex_TexelSize.xy;

				float4 c = (float4)0;
				for (int y = 0; y <= 2; y++) {
					for (int x = 0; x <= 2; x++) {
						float2 uv = i.uv + float2(x-1, y-1) * d;
						c += _BlurMat[y][x] * tex2D(_MainTex, uv);
					}
				}
				return c;
			}
			ENDCG
		}

		// Attenuation
		Pass {
			CGPROGRAM
			#pragma target 5.0
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			
			fixed4 frag (v2f i) : SV_Target {
				return (1.0 - _Atten) * tex2D(_MainTex, i.uv);
			}
			ENDCG
		}

		// Alpha Blend
		Pass {
			Blend One OneMinusSrcAlpha

			CGPROGRAM
			#pragma target 5.0
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			
			fixed4 frag (v2f i) : SV_Target {
				float4 c = tex2D(_MainTex, i.uv);
				return c;
			}
			ENDCG
		}
	}
}
