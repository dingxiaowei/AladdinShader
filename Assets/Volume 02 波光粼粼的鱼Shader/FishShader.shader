
//-----------------------------------------------【Shader说明】----------------------------------------------
//     Shader功能：   波光粼粼的鱼
//     使用语言：   Shaderlab
//     开发所用IDE版本：Unity2018.3.6 、Visual Studio 2017
//     2016年9月16日  Created by Aladdin(阿拉丁)   
//     更多内容或交流请访问我的博客：http://blog.csdn.net/s10141303/article/category/6670402
//---------------------------------------------------------------------------------------------------------------------

Shader "阿拉丁Shader编程/2-1.波光粼粼的鱼"{    Properties    {        _MainTex ("Texture", 2D) = "white" {}		_SubTex("SubTex",2D) = "white"{}		_Color("Color",Color) = (1,1,1,1)    }    SubShader    {        Tags{"RenderType"="Opaque"}
        LOD 100
        Pass 		{            CGPROGRAM            #pragma vertex vert 
            #pragma fragment frag 

			sampler2D _MainTex;			sampler2D _SubTex;			float4 _Color;

            struct a2v{
                fixed4 vertex:POSITION;
                fixed2 uv:TEXCOORD0;
            };

            struct v2f{
                fixed4 svPos:SV_POSITION;
				float2 uv:TEXCOORD0;
            };

            v2f vert(a2v v)
            {
                v2f f;
                f.uv = v.uv;
                f.svPos = UnityObjectToClipPos(v.vertex);
                return f;
            }
            fixed4 frag(v2f f):SV_Target
            {
                float2 offset = float2(0,0);				offset.x = _Time.y * 0.3f;                fixed4 col = tex2D(_MainTex, f.uv);				fixed subCol = tex2D(_SubTex, f.uv+ offset);				return (subCol + col) * _Color;
            }            ENDCG        }    }	FallBack  "Specular"}