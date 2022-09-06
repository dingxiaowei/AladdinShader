//-----------------------------------------------【Shader说明】--------------------------------------------------------
//     Shader功能：   2D圆角头像	
//	   核心思路：根据圆相关的知识，将正方形图分成四块象限区域然后每个象限一个最大的半径为0.5的圆，计算像素是否在圆角
//     之内是关键核心，首先计算四个圆心中间的像素，然后在根据像素距离圆心的长度是否交于半径，小于则在圆角之内，否则舍弃
//     使用语言：   Shaderlab
//     开发所用IDE版本：Unity2018.3.6 、Visual Studio 2017
//     2016年9月16日  Created by Aladdin(阿拉丁)   
//     更多内容或交流请访问我的博客：http://blog.csdn.net/s10141303/article/category/6670402
//---------------------------------------------------------------------------------------------------------------------

Shader "阿拉丁Shader编程/4-3.2D圆角头像" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_RADIUSBUCE("Radius(圆角半径)",Range(0,0.5))= 0.2   //圆角半径
	}
	SubShader
	{
		pass
		{
			CGPROGRAM
			#pragma exclude_renderers gles
			#pragma vertex vert
			#pragma fragment frag
			#include "unitycg.cginc"
			float _RADIUSBUCE;
			sampler2D _MainTex;

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 ModeUV: TEXCOORD0;
				float2 RadiusBuceVU : TEXCOORD1;
			};

			v2f vert(appdata_base v)
			{
				v2f o;
				o.pos=UnityObjectToClipPos(v.vertex); //v.vertex;
				o.ModeUV=v.texcoord;
				o.RadiusBuceVU=v.texcoord-float2(0.5,0.5);       //将模型UV坐标原点置为中心原点,为了方便计算  原本坐标原点在左下角
				return o;
			}


			fixed4 frag(v2f i):COLOR
			{
				fixed4 col;
				col=(0,1,1,0);

				if(abs(i.RadiusBuceVU.x)<0.5-_RADIUSBUCE||abs(i.RadiusBuceVU.y)<0.5-_RADIUSBUCE)   //像素点坐标在中间一块	不在四个角落	渲染原本的图元颜色
				{
					col=tex2D(_MainTex,i.ModeUV);
				}
				else //如果在四个角落
				{
					if(length(abs(i.RadiusBuceVU)-float2(0.5-_RADIUSBUCE,0.5-_RADIUSBUCE)) <_RADIUSBUCE)  //在圆角的内的像素 坐标到圆心的距离是否小于半径 小于则在圆角之内
					{
						col=tex2D(_MainTex,i.ModeUV);
					}
					else
					{
						discard;  //舍弃图元 相当于clip
					}		
				}
				return col;		
			}
			ENDCG
		}
	}
}
