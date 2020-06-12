// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "AladdinShader/02 VertexFrag Shader"
{
    Properties
    {
        _Color("_Color",Color) = (1,1,1,1)
        
    }
    SubShader {
        Pass 
        {
        CGPROGRAM
//顶点函数 这里只是声明了顶点函数的函数名
//基本作用是完成顶点坐标从模型空间到剪裁空间的转换(从游戏环境到视野相机屏幕上)
#pragma vertex vert
//片源函数 这里只是声明了片元函数的函数名
//基本作用是返回模型对应屏幕上的每一个像素颜色
#pragma fragment frag 

        //通过语义告诉系统我这个参数是干嘛的比如POSITION是模型坐标语义，告诉系统我需要顶点参数坐标  SV_POSITION是剪裁坐标语义
        float4 vert(float4 v:POSITION) :SV_POSITION
        {
            return UnityObjectToClipPos(v); //计算模型坐标转换成剪裁坐标
        }

        //SV_target是返回颜色语义
        float4 frag():SV_Target
        {
            return fixed4(1,1,1,1);
        }

        ENDCG
        }
    }
    FallBack  "VertexLit"
}