//-----------------------------------------------【Shader说明】--------------------------------------------------------
//     Shader功能：   2D圆角头像支持UGUI裁剪	
//	   核心思路：根据圆相关的知识，将正方形图分成四块象限区域然后每个象限一个最大的半径为0.5的圆，计算像素是否在圆角
//     之内是关键核心，首先计算四个圆心中间的像素，然后在根据像素距离圆心的长度是否交于半径，小于则在圆角之内，否则舍弃
//     使用语言：   Shaderlab
//     开发所用IDE版本：Unity2018.3.6 、Visual Studio 2017
//     2016年9月16日  Created by Aladdin(阿拉丁)   
//     更多内容或交流请访问我的博客：http://blog.csdn.net/s10141303/article/category/6670402
//---------------------------------------------------------------------------------------------------------------------

Shader "UI/2DUIRoundDefault"
{
    Properties
    {
        _MainTex ("Sprite Texture", 2D) = "white" {}
        _Color ("Tint", Color) = (1,1,1,1)
        _RADIUSBUCE("Radius(圆角半径)",Range(0,0.5)) = 0.2
        _StencilComp ("Stencil Comparison", Float) = 8
        _Stencil ("Stencil ID", Float) = 0
        _StencilOp ("Stencil Operation", Float) = 0
        _StencilWriteMask ("Stencil Write Mask", Float) = 255
        _StencilReadMask ("Stencil Read Mask", Float) = 255
        _ColorMask ("Color Mask", Float) = 15
    }

    SubShader
    {
        Tags
        {
            "Queue"="Transparent"
            "IgnoreProjector"="True"
            "RenderType"="Transparent"
            "PreviewType"="Plane"
            "CanUseSpriteAtlas"="True"
        }

        Stencil
        {
            Ref [_Stencil]
            Comp [_StencilComp]
            Pass [_StencilOp]
            ReadMask [_StencilReadMask]
            WriteMask [_StencilWriteMask]
        }

        Cull Off
        Lighting Off
        ZWrite Off
        ZTest [unity_GUIZTestMode]
        Blend One OneMinusSrcAlpha
        ColorMask [_ColorMask]

        Pass
        {
            Name "Default"
        CGPROGRAM
            #pragma exclude_renderers gles
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0

            #include "UnityCG.cginc"
            #include "UnityUI.cginc"

            #pragma multi_compile_local _ UNITY_UI_CLIP_RECT
            #pragma multi_compile_local _ UNITY_UI_ALPHACLIP

            struct appdata_t
            {
                float4 vertex   : POSITION;
                float4 color    : COLOR;
                float2 texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 RadiusBuceVU : TEXCOORD3;
                float2 ModeUV: TEXCOORD4;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            sampler2D _MainTex;
            float _RADIUSBUCE;

            v2f vert(appdata_t v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.ModeUV = v.texcoord;
                o.RadiusBuceVU = v.texcoord - float2(0.5, 0.5);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col;
                col = (0,1,1,0);

                if (abs(i.RadiusBuceVU.x) < 0.5 - _RADIUSBUCE || abs(i.RadiusBuceVU.y) < 0.5 - _RADIUSBUCE)
                {
                    col = tex2D(_MainTex,i.ModeUV);
                }
                else
                {
                    if (length(abs(i.RadiusBuceVU) - float2(0.5 - _RADIUSBUCE,0.5 - _RADIUSBUCE)) < _RADIUSBUCE)
                    {
                        col = tex2D(_MainTex,i.ModeUV);
                    }
                    else
                    {
                        discard;
                    }
                }
                return col;
            }
        ENDCG
        }
    }
}
