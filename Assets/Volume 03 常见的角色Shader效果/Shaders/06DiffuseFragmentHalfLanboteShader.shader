// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'


Shader "AladdinShader/06 Diffuse fragment Half Lanbote Shader"
{
    Properties
    {
        _Diffuse("Diffuse",Color)=(1,1,1,1) //添加自身的颜色
    }
    SubShader {
        Pass 
        {
            Tags{"LightMode"="ForwardBase"}

        CGPROGRAM
#include "Lighting.cginc" //引用一些写好的程序块 会包含一些获取光照的信息  
//_LightColor0 取得第一个直射光的颜色
//_WorldSpaceLightPos0 

#pragma vertex vert
#pragma fragment frag 
    
        fixed4 _Diffuse;

        struct a2v 
        {
            float4 vertex:POSITION;
            float3 normal:NORMAL; //模型空间下法线
        };

        struct v2f
        {
            float4 position:SV_POSITION;
            fixed3 worldNormalDir:COLOR0;
        };
        v2f vert(a2v v)
        {
            v2f f;
            f.position = UnityObjectToClipPos(v.vertex);
            f.worldNormalDir = mul(v.normal, (float3x3)unity_WorldToObject);
            return f;
        }

        fixed4 frag(v2f f):SV_Target
        {
            fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;//获得系统内置的环境光

            //获得世界空间的单位法线向量
            fixed3 normalDir = normalize(f.worldNormalDir); //从模型空间转到世界空间 float3x3 将一个4*4的矩阵强转成3*3的矩阵

            //世界空间下的光照位置
            fixed3  lightDir = _WorldSpaceLightPos0.xyz; //对于每一个点来说每一个光的位置就是光的方向（针对平行光）

            float halfLambert = dot(normalDir, lightDir) * 0.5 + 0.5; //半兰伯特光照模型
            //取得漫反射的颜色
            fixed3 diffuse = _LightColor0.rgb * halfLambert * _Diffuse.rgb;//取得第一个直射光的颜色 颜色融合
            fixed3 tempColor = diffuse + ambient;  //颜色增加 增强
            return fixed4(tempColor,1);
        }

        ENDCG
        }
    }
    FallBack  "VertexLit"
}