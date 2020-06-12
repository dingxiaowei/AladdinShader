// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "AladdinShader/03 Struct Shader"
{
    Properties
    {
        
    }
    SubShader {
        Pass 
        {
        CGPROGRAM
// Upgrade NOTE: excluded shader from DX11; has structs without semantics (struct v2f members tempNormal)
#pragma exclude_renderers d3d11
#pragma vertex vert
#pragma fragment frag 

        //a2v  application to vertex
        struct a2v 
        {
            //顶点坐标
            float4 vertex:POSITION; //添加上POSITION语义，这样操作系统才知道给这个变量赋值模型坐标变量
            //法线
            float3 normal:NORMAL; //告诉unity把模型空间下的法线方向向量填充给normal变量
            //纹理坐标(模型坐标对应贴图的坐标)
            //纹理坐标一般都是0-1 不按照实际的像素来的
            float4 texcoord:TEXCOORD0; //告诉unity把模型空间下的纹理坐标填充给texcoord变量
        };

        //v2f vertex to fragment
        struct v2f
        {
            float4 position:SV_POSITION;
            float3 tempNormal:COLOR0;
        };
        //通过语义告诉系统我这个参数是干嘛的比如POSITION是模型坐标语义，告诉系统我需要顶点参数坐标  SV_POSITION是剪裁坐标语义
        v2f vert(a2v v)
        {
            v2f f;
            f.position = UnityObjectToClipPos(v.vertex);//计算模型坐标转换成剪裁坐标
            f.tempNormal = v.normal;//将法线数据放到返回结构体里面供片元函数调用
            return f;
        }

        //SV_target是返回颜色语义
        fixed4 frag(v2f f):SV_Target
        {
            return fixed4(f.tempNormal,1);
        }

        ENDCG
        }
    }
    FallBack  "VertexLit"
}