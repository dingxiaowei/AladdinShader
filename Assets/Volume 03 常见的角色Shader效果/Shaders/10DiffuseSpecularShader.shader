// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "AladdinShader/10 Diffuse Specular Shader"
{
    Properties
    {
        _Diffuse("Diffuse Color", Color)=(1,1,1,1)
        _Specular("Specular Color", Color)=(1,1,1,1)
        _Gloss("Gloss",Range(10,200))=20
    }
    SubShader {
        Pass{
            //只有正确定义Tags 才能获取跟光相关的属性
            Tags { "LightMode"="ForwardBase" }
            CGPROGRAM
#include "Lighting.cginc" 
#pragma vertex vert 
#pragma fragment frag 

            fixed4 _Diffuse;
            fixed4 _Specular;
            half _Gloss;
            //顶点函数参数
            struct a2v{
                float4 vertex:POSITION; //顶点位置
                float3 normal:NORMAL; //模型空间下的法线
            };

            struct v2f{
                float4 svPos:SV_POSITION;
                fixed3 worldNormal:TEXCOORD0;//世界空间下的法线
                float4 worldVertex:TEXCOORD1;
            };

            v2f vert(a2v v)
            {
                v2f f;
                f.svPos = UnityObjectToClipPos(v.vertex); //模型空间位置到剪裁空间的顶点位置的转换
                f.worldNormal = UnityObjectToWorldNormal(v.normal); //模型空间的法线转成时间空间下的法线
                f.worldVertex = mul(v.vertex,unity_WorldToObject);
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
                //漫反射的颜色
                fixed3 diffuse = _LightColor0.rgb *_Diffuse.rgb * max(dot(normalDir, lightDir),0);
                
                //相机方向
                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(f.worldVertex));

                //光和相机方向的平分线
                fixed3 halfDir = normalize(lightDir + viewDir);
                //高光反射
                fixed3  specular = _LightColor0.rgb * _Specular.rgb * pow(max(dot(normalDir,halfDir),0),_Gloss);
                //环境光
                fixed3 tempColor = diffuse + specular + UNITY_LIGHTMODEL_AMBIENT.rgb;
                return fixed4(tempColor,1);
            }
            ENDCG
        }
    }
    FallBack  "Specular"
}