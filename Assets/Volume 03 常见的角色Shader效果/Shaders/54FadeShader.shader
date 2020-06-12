Shader "AladdinShader/54 Fade Shader"
{
    Properties
    {
        _MainTex("Main Tex", 2D) = "white"{}
        _Transparency("_Transparency", Range(0,1))=0.5
    }
    SubShader {
        //设置透明体
        Tags{"RenderType"="Transparent" "Queue"="Transparent"}
        LOD 100
        Pass {
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert 
            #pragma fragment frag 

            sampler2D _MainTex;
            fixed _Transparency;

            struct a2v{
                fixed4 vertex:POSITION;
                fixed4 normal:NORMAL;
                fixed2 uv:TEXCOORD0; 
            };

            struct v2f{
                fixed4 svPos:SV_POSITION;
                fixed2 uv:TEXCOORD1;
            };

            v2f vert(a2v v)
            {
                v2f f;
                f.uv = v.uv;
                f.svPos = UnityObjectToClipPos(v.vertex);
                return f;
            }
            fixed4 frag(v2f f):SV_Target
            {
                fixed4 color = tex2D(_MainTex, f.uv);
                color.a = _Transparency;
                return color;
            }
            ENDCG
        }
    }
    FallBack  "Specular"
}