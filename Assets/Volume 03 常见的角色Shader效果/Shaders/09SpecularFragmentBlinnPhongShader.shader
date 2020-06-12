// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "AladdinShader/09 Specular Fragment Blinn Phong Shader"
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
            float3 worldNormal:TEXCOORD0;//世界空间下的法线方向 
            float4 worldVertext:TEXCOORD1;//时间空间下的顶点坐标
        };
        v2f vert(a2v v)
        {
            v2f f;
            f.position = UnityObjectToClipPos(v.vertex);
            //法线从模型空间转成世界空间下
            // f.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
            f.worldNormal = UnityObjectToWorldNormal(v.normal); //使用内置方法转换
            f.worldVertext = mul(v.vertex , unity_WorldToObject);
            return f;
        }

        fixed4 frag(v2f f):SV_Target
        {
            fixed3 adbient = UNITY_LIGHTMODEL_AMBIENT.rgb;
            fixed3 normalDir = normalize(f.worldNormal);

            //光源方向
            // fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);//对于每个顶点来说 光的位置就是光的方向 因为是平行光
            fixed3 lightDir = normalize(WorldSpaceLightDir(f.worldVertext).xyz); //模型空间中的顶点坐标=>世界空间中从这个点到光源的方向

            fixed3 diffuse = _LightColor0.rgb * max(dot(normalDir,lightDir), 0) * _Diffuse.rgb;//取得漫反射的颜色
            
            //反射光方向
            //fixed3 reflectDir = normalize(reflect(-lightDir,normalDir));
            //视野方向
            //相机是在世界空间下              
            // fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - f.worldVertext);
            fixed3 viewDir = normalize(UnityWorldSpaceViewDir(f.worldVertext));
            //平分线
            fixed3 halfDir = normalize(viewDir + lightDir);  //视野方向和光照方向的平分线

            //高光反射
            fixed3 specular = _LightColor0.rgb * pow(max(dot(normalDir,halfDir),0),_Gloss) * _Specular.rgb;
            fixed3 tempColor = diffuse + adbient + specular;
            return fixed4(tempColor, 1);
        }

        ENDCG
        }
    }
    FallBack  "VertexLit"
}