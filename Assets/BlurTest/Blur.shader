Shader "BanMing/ImageBlur"
{
    Properties
    {
        _BlurSize("Blur Size", Float) = 1.0
        _Color("Color", Color) = (1, 1, 1, 1)
    }
        SubShader
    {
        //因为我们需要记录当前的屏幕所以是需要透明通道
        Tags {"Queue" = "Transparent"}

        CGINCLUDE

        sampler2D _GrabTexture;
        half4 _GrabTexture_TexelSize;
        float _BlurSize;
        float4 _Color;

        struct v2f
        {
            // float4 grabPos : TEXCOORD0; 
            float4 uv[5] : TEXCOORD1;
            float4 vertex : SV_POSITION;
        };

        //公用模糊片面函数
        fixed4 fragBlur(v2f i) : SV_Target
        {
            float weight[3] = {0.4026, 0.2442, 0.0545};

            fixed4 sum = tex2Dproj(_GrabTexture, i.uv[0]) * weight[0];
            for (int index = 1; index < 3; index++) {
                sum += tex2Dproj(_GrabTexture, i.uv[index]) * weight[index];
                sum += tex2Dproj(_GrabTexture, i.uv[2 * index]) * weight[index];
            }
            return sum * _Color;
        }
        ENDCG

            //横向模糊
            GrabPass {}

            Pass
            {
                CGPROGRAM
                #pragma vertex vert
                    #pragma fragment fragBlur

                #include "UnityCG.cginc"


                v2f vert(appdata_base v)
                {
                    v2f o;
                    o.vertex = UnityObjectToClipPos(v.vertex);
                    //获得屏幕填色
                    float4 grabPos = ComputeGrabScreenPos(o.vertex);

                    o.uv[0] = grabPos;

                    o.uv[1].xy = grabPos.xy + float2(_GrabTexture_TexelSize.x, 0.0) * _BlurSize;
                    o.uv[1].zw = grabPos.zw;

                    o.uv[2].xy = grabPos.xy - float2(_GrabTexture_TexelSize.x, 0.0) * _BlurSize;
                    o.uv[2].zw = grabPos.zw;

                    o.uv[3].xy = grabPos.xy + float2(_GrabTexture_TexelSize.x * 2, 0.0) * _BlurSize;
                    o.uv[3].zw = grabPos.zw;

                    o.uv[4].xy = grabPos.xy - float2(_GrabTexture_TexelSize.x * 2, 0.0) * _BlurSize;
                    o.uv[4].zw = grabPos.zw;

                    return o;
                }

                ENDCG
            }

                //纵向模糊
                GrabPass {}

                Pass
                {
                    CGPROGRAM
                    #pragma vertex vert
                        #pragma fragment fragBlur

                    #include "UnityCG.cginc"


                    v2f vert(appdata_base v)
                    {
                        v2f o;
                        o.vertex = UnityObjectToClipPos(v.vertex);
                        //获得屏幕填色
                        float4 grabPos = ComputeGrabScreenPos(o.vertex);

                        o.uv[0] = grabPos;

                        o.uv[1].xy = grabPos.xy + float2(0.0, _GrabTexture_TexelSize.y) * _BlurSize;
                        o.uv[1].zw = grabPos.zw;

                        o.uv[2].xy = grabPos.xy - float2(0.0, _GrabTexture_TexelSize.y) * _BlurSize;
                        o.uv[2].zw = grabPos.zw;

                        o.uv[3].xy = grabPos.xy + float2(0.0, _GrabTexture_TexelSize.y * 2) * _BlurSize;
                        o.uv[3].zw = grabPos.zw;

                        o.uv[4].xy = grabPos.xy - float2(0.0, _GrabTexture_TexelSize.y * 2) * _BlurSize;
                        o.uv[4].zw = grabPos.zw;

                        return o;
                    }
                    ENDCG
                }
    }
}