// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "AladdinShader/12 Rock Shader"
{
    Properties
    {
        // _Diffuse("Diffuse Color", Color)=(1,1,1,1) //漫反射的颜色
        _MainTex("Main Tex", 2D) = "white"{} //纹理贴图 默认白色
        _Color("Color", Color) = (1,1,1,1) //整体一个色调

    }
    SubShader {
        Pass{
            //只有正确定义Tags 才能获取跟光相关的属性
            Tags { "LightMode"="ForwardBase" }
            CGPROGRAM
#include "Lighting.cginc" 
#pragma vertex vert 
#pragma fragment frag 

            // fixed4 _Diffuse;
            sampler2D _MainTex;
            fixed4 _Color;
            fixed4 _Specular;
            float4 _MainTex_ST;

            //顶点函数参数
            struct a2v{
                float4 vertex:POSITION; //顶点位置
                float3 normal:NORMAL; //模型空间下的法线

                //纹理坐标只能在定点函数取到
                float4 texcoord:TEXCOORD0; 
            };

            struct v2f{
                float4 svPos:SV_POSITION;
                fixed3 worldNormal:TEXCOORD0;//世界空间下的法线
                float4 worldVertex:TEXCOORD1;

                //将取到的纹理坐标传递到片元函数
                float2 uv:TEXCOORD2;
            };

            v2f vert(a2v v)
            {
                v2f f;
                f.svPos = UnityObjectToClipPos(v.vertex); //模型空间位置到剪裁空间的顶点位置的转换
                f.worldNormal = UnityObjectToWorldNormal(v.normal); //模型空间的法线转成时间空间下的法线
                f.worldVertex = mul(v.vertex,unity_WorldToObject);
                f.uv = v.texcoord.xy * _MainTex_ST.xy +_MainTex_ST.zw; //乘以Tiling缩放 + Offset旋转
                return f;
            } 

            //片元函数返回颜色
            fixed4 frag(v2f f):SV_Target{
                //漫反射
                //漫反射颜色 先不管透明度
                //_LightColor0 平行光的颜色 cos夹角 光的方向和视野的夹角
                fixed3 normalDir = normalize(f.worldNormal);
                //光的方向
                fixed3 lightDir = normalize(WorldSpaceLightDir(f.worldVertex));

                //返回贴图上某像素颜色的值
                fixed3 texColor = tex2D(_MainTex, f.uv.xy) * _Color.rgb;

                //漫反射的颜色
                // fixed3 diffuse = _LightColor0.rgb *_Diffuse.rgb * max(dot(normalDir, lightDir),0);
                fixed3 diffuse = _LightColor0.rgb * texColor * max(dot(normalDir, lightDir), 0);

                fixed3 tempColor = diffuse + UNITY_LIGHTMODEL_AMBIENT.rbg * texColor;
                return fixed4(tempColor,1);
            }
            ENDCG
        }
    }
    FallBack  "Specular"
}