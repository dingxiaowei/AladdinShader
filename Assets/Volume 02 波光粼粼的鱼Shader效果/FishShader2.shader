
//-----------------------------------------------【Shader说明】----------------------------------------------
//     Shader功能：   波光粼粼的鱼 shader控制鱼的游动
//     使用语言：   Shaderlab
//     开发所用IDE版本：Unity2018.3.6 、Visual Studio 2017
//     2019年4月10日  Created by Aladdin(阿拉丁)   
//     更多内容或交流请访问我的博客：http://blog.csdn.net/s10141303/article/category/6670402
//---------------------------------------------------------------------------------------------------------------------

Shader "阿拉丁Shader编程/2-2.波光粼粼的鱼(Shader控制鱼的游动)"
{
	Properties 
	{
		_MainTex ("MainTexture", 2D) = "white" {}
		_SubTexture("SubTexture",2D) = "white"{}
		_FlowColor("FlowColor",Color) = (1,0,0,1)
		_Speed("Speed",float) = 0.5
		_Frenquacy("Frenquacy",float) = 1
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
			#include"UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;

			sampler2D _SubTexture;

			float4 _FlowColor;
			float _Speed;
			float _Frenquacy;

			struct a2v
			{
				float4 vertex:POSITION;
				float2 uv:TEXCOORD0;
			};

			struct v2f
			{
				float2 uv:TEXCOORD0;
				float4 vertex:SV_POSITION;
			};

			v2f vert(a2v v)
			{
				v2f o;
				float timer = _Time.y * _Speed;
				float waverX = cos(timer + v.vertex.x)*_Frenquacy;	//鱼游动 取代animator
				v.vertex.x = v.vertex.x + waverX;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv,_MainTex);  
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				float2 offset = float2(0,0);
				offset.x = _Time.y * 0.1;
				offset.y = _Time.y * 0.1;

				fixed4 subCol = tex2D(_SubTexture,i.uv + offset) * _FlowColor;

				fixed4 col = tex2D(_MainTex,i.uv);

				return subCol + col;
			}
			ENDCG
		}//end Pass
	}//end SubShader
}//end Shader
