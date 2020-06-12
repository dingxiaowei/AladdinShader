// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "AladdinShader/13 Rock Normal Map Shader"
{
    Properties
    {
        _MainTex("Main Tex", 2D) = "white"{} //纹理贴图 默认白色
        _Color("Color", Color) = (1,1,1,1) //整体一个色调
        _NormalMap("NormalMap", 2D) = "bump"{} //bump这个位置没有使用法线贴图的时候就使用模型自带的法线  使用的是切线空间
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
            sampler2D _NormalMap;
            float4 _NormalMap_ST; //法线贴图的ST

            //顶点函数参数
            struct a2v{
                float4 vertex:POSITION; //顶点位置
                //切线空间的确定是通过（存储到模型里面的）法线和（存储到模型里面的）切线确定的
                float3 normal:NORMAL; 
                float4 tangent:TANGENT; //TANGENT.w是用来确定切线空间中坐标轴的方向的
                //纹理坐标只能在定点函数取到
                float4 texcoord:TEXCOORD0; 
            };

            struct v2f{
                float4 svPos:SV_POSITION;
                //fixed3 worldNormal:TEXCOORD0;//世界空间下的法线
                //切线空间下 平行光的方向
                float3 lightDir:TEXCOORD0; 
                float4 worldVertex:TEXCOORD1;
                //将取到的纹理坐标传递到片元函数
                float4 uv:TEXCOORD2;  //xy 用来存储MainTex的纹理坐标 zw用来存存储NormalMap的纹理坐标
            };

            v2f vert(a2v v)
            {
                v2f f;
                f.svPos = UnityObjectToClipPos(v.vertex); //模型空间位置到剪裁空间的顶点位置的转换
                //f.worldNormal = UnityObjectToWorldNormal(v.normal); //模型空间的法线转成时间空间下的法线
                f.worldVertex = mul(v.vertex,unity_WorldToObject);
                f.uv.xy = v.texcoord.xy * _MainTex_ST.xy +_MainTex_ST.zw; //乘以Tiling缩放 + Offset旋转
                f.uv.zw = v.texcoord.xy * _NormalMap_ST.xy + _NormalMap_ST.zw;
                
                TANGENT_SPACE_ROTATION;//调用这个之后会得到一个矩阵 rotation 这个矩阵用来把模型空间下的方向转换成切线空间下  调用这个还必须要求a2v 的变量是V 并且它里面要有切线空间下的法线normal和切线tangent这两个变量 在这个方法里面会使用
                //得到模型空间下的光的方向
                //ObjSpaceLightDir(v.vertex) //得到模型空间下的平行光方向
                f.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex));
                return f;
            } 

            //把所有跟法线方向有关的运算都放在切线空间下
            //从法线贴图里取得的法线方向都是在切线空间下的
            fixed4 frag(v2f f):SV_Target{
                //取得贴图里面获得的法线
                //获取颜色值
                fixed4 normalColor = tex2D(_NormalMap,f.uv.zw);

                //切线空间下的法线
                //fixed3 tangentNormal = normalize(normalColor.xyz * 2 - 1);  //unity里面直接将法线贴图设置成NormalMap就会做一些处理，然后用系统方法提取法线 而不用我们自己计算
                //提取法线
                fixed3 tangentNormal = UnpackNormal(normalColor);
                tangentNormal = normalize(tangentNormal);

                //光的方向
                fixed3 lightDir = normalize(f.lightDir);

                //返回贴图上某像素颜色的值
                fixed3 texColor = tex2D(_MainTex, f.uv.xy) * _Color.rgb;

                fixed3 diffuse = _LightColor0.rgb * texColor * max(dot(tangentNormal, lightDir), 0);

                fixed3 tempColor = diffuse + UNITY_LIGHTMODEL_AMBIENT.rbg * texColor;
                return fixed4(tempColor,1);
            }
            ENDCG
        }
    }
    FallBack  "Specular"
}