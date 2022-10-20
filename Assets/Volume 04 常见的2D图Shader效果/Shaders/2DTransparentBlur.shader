Shader "阿拉丁Shader编程/4.7 TransparentBlur"
{
	Properties
	{
		[PerRendererData] _MainTex("Sprite Texture", 2D) = "white"{}
		_Color("Tint",color) = (1,1,1,1)//混合预设的颜色
		[MaterialToggle] PiexlSnap("Pixel snap", Float) = 0

		_TextureSize("_Texture Size", Float) = 256
			//模糊半径
			_BlurRadius("_Blur Radius", Range(1, 25)) = 1
			//模糊效果的透明度，0是完全模糊，1是完全清晰
			_Alpha("_Alpha", Range(0.0, 1.0)) = 0.5
			//去色效果透明度,0是原来的颜色，1是完全黑白
			_GrayRate("_Gray Rate", Range(0.0, 1.0)) = 0

			//required for UI.Mask
			_StencilComp("Stencil Comparison", Float) = 8
			_Stencil("Stencil ID", Float) = 0
			_StencilOp("Stencil Operation", Float) = 0
			_StencilWriteMask("Stencil Write Mask",Float) = 255
			_StencilReadMask("Stencil Read Mask",Float) = 255
			_ColorMask("Color Mask",Float) = 15
	}
		SubShader
		{
			Tags
			{
				"Queue" = "Transparent"
				"IgnoreProjector" = "True"
				"RenderType" = "Transparent"
				"PreviewType" = "Plane"
				"CanUseSpriteAtlas" = "True"
			}

			cull off
			Lighting off
			ZWrite off
			Fog{ Mode off }
			ColorMask RGB
			Blend one oneMinusSrcAlpha

			stencil
			{
				Ref[_Stencil]
				Comp[_StencilComp]
				Pass[_StencilOp]
				ReadMask[_StencilReadMask]
				WriteMask[_StencilWriteMask]
			}
			ColorMask[_ColorMask]

			GrabPass
			{
				"_BgColor"
			}

			Pass
			{
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma multi_compile DUMMY PIXELSNAP_ON
				#include "UnityCG.cginc"

				struct appdata_t {
					float4 vertex : POSITION;
					float4 color : COLOR;
					float2 texcoord : TEXCOORD0;
				};

				struct v2f
				{
					float4 vertex : SV_POSITION;
					float4 color : COLOR;
					half2 texcoord : TEXCOORD0;
					float4 grabPos : TEXCOORD1;//for _BgColor
				};

				fixed4 _Color;

				v2f vert(appdata_t IN) {
					v2f OUT;
					OUT.vertex = UnityObjectToClipPos(IN.vertex);
					OUT.texcoord = IN.texcoord;
					OUT.grabPos = ComputeGrabScreenPos(OUT.vertex);
					OUT.color = IN.color * _Color;
					#ifdef PIXELSNAP_ON
					OUT.vertex = UnityPixelSnap(OUT.vertex);
					#endif

					return OUT;
				}

				sampler2D _MainTex;
				sampler2D _BgColor;
				float _TextureSize;
				float _BlurRadius;

				//高斯模糊算法
				float GetGaussianDistribution(float x, float y, float rho) {
					float g = 1.0f / sqrt(2.0f * 3.141592654f * rho * rho);
					return g * exp(-(x * x + y * y) / (2 * rho * rho));
				}
				float4 GetGaussBlurColor(sampler2D blurTex, float2 uv) {
					float space = 1.0 / _TextureSize;
					float rho = (float)_BlurRadius * space / 3.0;
					float weightTotal = 0;
					for (int x = -_BlurRadius; x <= _BlurRadius; x++) {
						for (int y = -_BlurRadius; y <= _BlurRadius; y++) {
							weightTotal += GetGaussianDistribution(x * space, y * space, rho);
						}
					}
					float4 colorTmp = float4(0, 0, 0, 0);
					for (int x = -_BlurRadius; x <= _BlurRadius; x++) {
						for (int y = -_BlurRadius; y <= _BlurRadius; y++) {
							float weight = GetGaussianDistribution(x * space, y * space, rho) / weightTotal;
							float4 color = tex2D(blurTex, uv + float2(x * space, y * space));
							color = color * weight;
							colorTmp += color;
						}
					}
					return colorTmp;
				}

				float _Alpha;
				float _GrayRate;

				fixed4 frag(v2f IN) : SV_Target
				{
					fixed4 c = tex2D(_MainTex, IN.texcoord);
					float2 sceneUVs = (IN.grabPos.xy / IN.grabPos.w);
					float4 blurCol = GetGaussBlurColor(_BgColor, sceneUVs);
					//模糊与清晰的比重
					c = (c * _Alpha) + (blurCol * (1 - _Alpha));
					c *= IN.color;

					//去色效果比重
					float gray = dot(c.xyz, float3(0.299, 0.587, 0.114));
					c.xyz = float3(gray, gray, gray) * _GrayRate + c.xyz * ((1 - _GrayRate));

					return c;
				}

				ENDCG
			}
		}
}
