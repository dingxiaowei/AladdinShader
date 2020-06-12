// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "AladdinShader/07 Specular Vertex Shader"
{
    Properties
    {
        _Diffuse("Diffuse",Color)=(1,1,1,1) //添加自身的颜色
        _Specular("Specular",Color)=(1,1,1,1)
        _Gloss("Gloss",Range(8,200)) = 10
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
        fixed4 _Specular;
        half _Gloss;

        struct a2v 
        {
            float4 vertex:POSITION;
            float3 normal:NORMAL; //模型空间下法线
        };

        struct v2f
        {
            float4 position:SV_POSITION;
            fixed3 color:COLOR;
        };
        v2f vert(a2v v)
        {
            v2f f;
            f.position = UnityObjectToClipPos(v.vertex);
            fixed3 adbient = UNITY_LIGHTMODEL_AMBIENT.rgb;
            fixed3 normalDir = normalize(mul(v.normal,(float3x3)unity_WorldToObject));
            fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);//对于每个顶点来说 光的位置就是光的方向 因为是平行光
            fixed3 diffuse = _LightColor0.rgb * max(dot(normalDir,lightDir), 0) * _Diffuse.rgb;//取得漫反射的颜色
            
            //反射光方向
            fixed3 reflectDir = normalize(reflect(-lightDir,normalDir));
            //视野方向
            //相机是在世界空间下              
            fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - mul(v.vertex,unity_WorldToObject).xyz);

            //高光反射
            fixed3 specular = _LightColor0.rgb * pow(max(dot(reflectDir,viewDir),0),_Gloss) * _Specular.rgb;
            f.color = diffuse + adbient + specular;
            return f;
        }

        fixed4 frag(v2f f):SV_Target
        {
            return fixed4(f.color, 1);
        }

        ENDCG
        }
    }
    FallBack  "VertexLit"
}