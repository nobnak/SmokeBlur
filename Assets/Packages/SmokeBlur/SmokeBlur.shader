Shader "Hidden/SmokeBlur" {
	Properties {
		_MainTex ("Texture", 2D) = "white" {}
		_SubTex ("Sub Texture", 2D) = "black" {}
		_Accum ("Accumulation", Range(0.01, 1)) = 0.01
		_Atten ("Attenuation", Range(0, 1)) = 0.01
		_Depth ("Smoke Depth", Float) = 0.01
	}
	SubShader {
		Cull Off ZWrite Off ZTest Always
		ColorMask RGBA

		CGINCLUDE
			#pragma target 5.0
			#include "UnityCG.cginc"
			#include "Depth.cginc"

			struct appdata {
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};
			struct v2f {
				float2 uv : TEXCOORD0;
				float2 uv1 : TEXCOORD1;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_TexelSize;
			sampler2D _SubTex;
			float4 _SubTex_TexelSize;
			float4x4 _BlurMat;
			float _Accum;
			float _Atten;
			float _Depth;

			sampler2D _CameraDepthTexture;

			v2f vert (appdata v) {
				float2 uvFromBottom = v.uv;
				if (_MainTex_TexelSize.y < 0)
					uvFromBottom.y = 1 - uvFromBottom.y;

				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = v.uv;
				o.uv1 = uvFromBottom;
				return o;
			}
		ENDCG

		// Accumulation
		Pass {
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			fixed4 frag (v2f i) : SV_Target {
				fixed4 c = tex2D(_MainTex, i.uv);
				return float4(c.rgb, c.a * _Accum);
			}
			ENDCG
		}

		// Blur
		Pass {
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
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
			#pragma vertex vert
			#pragma fragment frag
			
			fixed4 frag (v2f i) : SV_Target {
				return (1.0 - _Atten) * tex2D(_MainTex, i.uv);
			}
			ENDCG
		}

		// Depth Alpha Blend
		Pass {
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			fixed4 frag (v2f i) : SV_Target {
				float zeye = Z2EyeDepth(tex2D(_CameraDepthTexture, i.uv1));
				float4 csrc = tex2D(_MainTex, i.uv);
				float4 csmoke = tex2D(_SubTex, i.uv1);

				float d = saturate(csmoke.a * (1.0 - exp(-zeye * _Depth)));
				return lerp(csrc, csmoke, d);
			}
			ENDCG
		}
	}
}
